require 'net/ssh'

module Docker
  class SshWrapper
    attr_accessor :ssh

    def initialize host, user="root", password
      @host = host
      @user = user
      @password = password
    end

    protected

    def log msg
      $stdout.puts "[#{self.class.to_s} LOG]: "+msg
    end

    def err msg
      $stderr.puts "[#{self.class.to_s} ERR] "+msg
    end

    def connect
      begin
        Net::SSH.start(@host, 'root', password: ENV['password']) do |ssh|
          log "Connected!"
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
  end
end
