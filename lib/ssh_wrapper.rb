require 'net/ssh'
require 'net/scp'
require "resolv"

class SshWrapper
  attr_accessor :ssh
  NAME_PATTERN = /^[a-zA-Z0-9][a-zA-Z\-\_0-9]*[a-zA-Z0-9]$/

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

  protected

  def log msg
    $stdout.puts "[#{self.class.to_s} LOG]: "+msg
  end

  def err msg
    $stderr.puts "[#{self.class.to_s} ERR]: "+msg
  end

  def connect
    begin
      Net::SSH.start(@host, 'root', password: ENV['password']) do |ssh|
        log "Connected to #{@name}"
        @ssh = ssh
        yield
      end
    rescue Net::SSH::HostKeyMismatch => ex
      log "Host key mismatch! #{ex.message}\nContinue anyway? (yes/no)"
      choice = $stdin.gets
      if choice[0].downcase == "y"
        ex.remember_host!
        retry
      else
        exit(2)
      end
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

  def remote_write remote_path, content
    ssh.exec! "cat > #{remote_path} << EOF\n#{content}\nEOF\n"
    log "Wrote #{content.length} bytes to #{@host}:#{remote_path}"
  end
end
