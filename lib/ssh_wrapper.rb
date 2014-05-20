require 'net/ssh'
require 'net/scp'
require "resolv"
require 'tempfile'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

class SshWrapper
  attr_accessor :ssh, :scp
  NAME_PATTERN = /^[a-zA-Z0-9][a-zA-Z\-\_0-9]*[a-zA-Z0-9]$/
  SSH_PRIVATE_KEY = Rails.root.join("config/ssh/id_rsa")
  SSH_PUBLIC_KEY = Rails.root.join("config/ssh/id_rsa.pub")
  SSH_KNOWN_HOSTS_FILE = Rails.root.join("config/ssh/known_hosts")

  def initialize ip, user=(ENV['user'] ? ENV['user'] : "root"), password, name
    ssh_dir = Rails.root.join("config/ssh")
    FileUtils.mkdir ssh_dir unless ssh_dir.exist?
    if ip =~ Resolv::IPv4::Regex
      @host = ip
    else
      raise "#{ip} is not a valid IPv4 address"
    end
    @user = user
    @password = password
    if name =~ NAME_PATTERN
      @name = name
    else
      raise "name was not valid. pattern: #{NAME_PATTERN}"
    end
    @after = [] # we put our log_after messages here
  end

  def start options={}
    connect do
      if ubuntu_lts?
        if v = options[:version]
          unless ubuntu_version_matches?(v)
            err "Requires Ubuntu #{v}!"
            exit(2)
          end
        end
        yield
        @after.each {|msg| log msg }
      else
        err "This is not an Ubuntu LTS server! Cannot continue."
        exit(2)
      end
    end
  end

  def ubuntu_lts?
    ssh.exec!('lsb_release -rs') =~ /1(2|4).04/
  end

  def ubuntu_1204?
    ubuntu_version_matches? "12.04"
  end

  def ubuntu_1404?
    ubuntu_version_matches? "14.04"
  end

  def ubuntu_version_matches? str
    ssh.exec!('lsb_release -rs') =~ /#{str}/
  end

  def package_installed? name
    output = ssh.exec!("apt-cache policy #{name}")
    !!(output =~ /Installed/) && !!!(output =~ /Installed: \(none\)/)
  end

  def command_missing? cmd
    !ssh.exec!(%{hash #{cmd} 2>&1 /dev/null || echo "MISSING"}).nil?
  end

  def file_exists? remote_path
    !!!ssh.exec!("stat #{remote_path}").match(/No such file or directory/)
  end

  def needs_package pkg
    if package_installed? pkg
      yield if block_given?
    else
      log "Installing package: #{pkg}"
      script = "DEBIAN_FRONTEND=noninteractive apt-get install -y #{pkg}"
      if block_given?
        stream_exec(script) { yield }
      else
        ssh.exec!(script)
      end
    end
  end

  def remote_write remote_path, content
    file = Tempfile.new('remote_write')
    begin
      file.write content
      file.close
      scp.upload! file.path, remote_path
      log "Wrote #{content.length} bytes to #{@host}:#{remote_path}"
    ensure
      file.unlink
    end
  end

  def remote_append remote_path, content
    file = Tempfile.new('remote_append')
    begin
      file.write content
      file.close
      scp.upload! file.path, "/tmp/remote_append"
      ssh.exec! "cat /tmp/remote_append >> #{remote_path}"
      log "Appended #{content.length} bytes to #{@host}:#{remote_path}"
    ensure
      file.unlink
    end
  end

  def connect
    begin
      log "Attempting password-less login"
      Net::SSH.start(@host, @user, { keys: [SSH_PRIVATE_KEY.to_s], keys_only: true, timeout: 5000,
                                      user_known_hosts_file: SSH_KNOWN_HOSTS_FILE.to_s }) do |ssh|
        connected ssh
        yield
      end
    rescue Net::SSH::AuthenticationFailed
      err "Passwordless login failed. Attempting to login with password"
      begin
        configure_passwordless_login
        sleep 1
        retry
      rescue Net::SSH::AuthenticationFailed
        err "Incorrect password. Giving up."
        exit(2)
      end
    rescue Net::SSH::HostKeyMismatch => ex
      err "Host key mismatch! #{ex.message}\nContinue anyway? (yes/no)"
      choice = $stdin.gets
      if choice[0].downcase == "y"
        ex.remember_host!
        retry
      else
        exit(2)
      end
    end
  end

  def log_after msg
    @after << msg
    return msg
  end

  def log msg
    msg.to_s.split("\n").each do |line|
      $stdout.puts "[#{@user}@#{@host}]: #{line}".green
    end
  end

  def err msg
    msg.to_s.split("\n").each do |line|
      $stdout.puts "[#{@user}@#{@host}]: #{line}".red
    end
  end

  def stream_exec cmd
    channel = ssh.open_channel do |ch|
      ch.exec(cmd) do |ch, success|
        raise "could not execute command" unless success

        # "on_data" is called when the process writes something to stdout
        ch.on_data do |c, data|
          log data
        end

        # "on_extended_data" is called when the process writes something to stderr
        ch.on_extended_data do |c, type, data|
          err data
        end

        ch.on_close { yield } if block_given?
      end
      channel.wait
    end
  end

  private

  def connected ssh
    log "Connected to #{@name}"
    @ssh = ssh
    @scp = ssh.scp
  end

  def generate_keypair
    log "Generating local keypair"
    system(%{ssh-keygen -t rsa -f #{SSH_PRIVATE_KEY} -N ""})
    unless SSH_PRIVATE_KEY.exist? 
      err "Failed to generate keypair"
      exit(2)
    else
      log log_after "Generated new private key #{SSH_PRIVATE_KEY}"
      log log_after "Generated new public key #{SSH_PUBLIC_KEY}"
    end
  end

  def configure_passwordless_login
    generate_keypair unless SSH_PRIVATE_KEY.exist?
    Net::SSH.start(@host, @user, password: ENV['password']) do |ssh|
      connected ssh
      ssh.exec!("mkdir ~/.ssh")
      remote_append "~/.ssh/authorized_keys", SSH_PUBLIC_KEY.read
      log "Disabling future password authentication attempts"
      remote_append "/etc/ssh/sshd_config", "PasswordAuthentication no"
      ssh.exec!("service ssh restart")
      log "Restarting ssh..."
    end
  end

  def execute_batch cmd
    if cmd.respond_to? :call
      instance_eval &cmd 
    elsif cmd.is_a? Hash
      execute_scripts_hash cmd
    elsif cmd.is_a? Array
      execute_scripts_array cmd
    else
      log ssh.exec!(cmd)
    end
  end

  def execute_scripts_array scripts_array
    scripts_array.each do |cmd|
      execute_batch cmd
    end
  end

  def execute_scripts_hash scripts_hash
    scripts_hash.each do |desc, cmd|
      log desc.to_s if desc.to_s.length > 0
      execute_batch cmd
    end
  end

  def enable_initd_service name
    log ssh.exec!("update-rc.d #{name} defaults")
    log ssh.exec!("/etc/init.d/#{name} stop")
    log ssh.exec!("/etc/init.d/#{name} start")
  end

  ##
  # Update something in the .env file
  def update_local_env *args
    raise ArgumentError unless args.is_a? Hash
    env = Dotenv.load
    args.each do |key, val|
      env[key] = val
      log log_after "Env Updated: #{key}=#{val}!"
    end
    File.open(Rails.root.join(".env"), 'w') do |file|
      env.each {|k,v| file.puts "#{k}=#{v}" }
    end
    log_after "Environment has changed. Please reprovision all hosts!"
  end
end
