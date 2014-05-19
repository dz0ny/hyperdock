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
  PRIVATE_KEY = Pathname.new File.expand_path "~/.ssh/id_rsa"
  PUBLIC_KEY = Pathname.new File.expand_path "~/.ssh/id_rsa.pub"

  def initialize ip, user="root", password, name
    if ip =~ Resolv::IPv4::Regex
      @host = ip
    else
      raise "#{ip} is not a valid IPv4 address"
    end
    @user = user
    @password = password
    if name.match(NAME_PATTERN)
      @name = name
    else
      raise "name was not valid. pattern: #{NAME_PATTERN}"
    end
  end

  def start options={}
    connect do
      if ubuntu_lts?
        if v = options[:version]
          if ubuntu_version_matches?(v)
            yield
          else
            err "Requires Ubuntu #{v}!"
            exit(2)
          end
        else
          yield
        end
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
      yield
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
      Net::SSH.start(@host, 'root') do |ssh|
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
    @scp = Net::SCP.new(@ssh)
  end

  def generate_keypair
    log "Generating local keypair"
    log system(%{ssh-keygen -t rsa -f #{PRIVATE_KEY} -N ""})
    unless PRIVATE_KEY.exist? 
      err "Failed to generate keypair"
      exit(2)
    else
      log "Generated private key #{PRIVATE_KEY}"
      log "Generated public key #{PUBLIC_KEY}"
    end
  end

  def configure_passwordless_login
    generate_keypair unless PRIVATE_KEY.exist?
    Net::SSH.start(@host, 'root', password: ENV['password']) do |ssh|
      connected ssh
      ssh.exec!("mkdir ~/.ssh")
      remote_append "~/.ssh/authorized_keys", PUBLIC_KEY.read
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
end
