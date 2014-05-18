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
    msg.to_s.split("\n").each do |line|
      $stdout.puts "[#{@user}@#{@host}]: #{line}".green
    end
  end

  def err msg
    msg.to_s.split("\n").each do |line|
      $stdout.puts "[#{@user}@#{@host}]: #{line}".red
    end
  end

  def connect
    log "Connecting over SSH"
    begin
      Net::SSH.start(@host, 'root', password: ENV['password']) do |ssh|
        log "Connected to #{@name}"
        @ssh = ssh
        @scp = Net::SCP.new(@ssh)
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
end
