module Hyperdock
  module LogstashForwarderSetup
    LUMBERJACK_INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/logstash-forwarder
      rm -f /etc/logstash-forwarder
      rm -f /etc/init.d/logstash-forwarder
      rm -rf /opt/go /opt/go*
      rm -rf /usr/local/go
      cd /opt

      wget https://storage.googleapis.com/golang/go1.2.2.linux-amd64.tar.gz 2>/dev/null
      tar -zxvf go1.2.2.linux-amd64.tar.gz 1>/dev/null
      ln -s /opt/go /usr/local/go

      git clone https://github.com/elasticsearch/logstash-forwarder.git
      cd logstash-forwarder
      /opt/go/bin/go build
      mkdir bin
      mv logstash-forwarder bin
    EOF
    LUMBERJACK = {
      key: Rails.root.join('config/logstash/ssl/key.pem'),
      cert: Rails.root.join('config/logstash/ssl/cert.pem'),
      conf: Rails.root.join('config/logstash/forwarder'),
      init: Rails.root.join('config/logstash/forwarder.init')
    }

    def use_logstash_forwarder! &block
      if LUMBERJACK[:key].exist? && LUMBERJACK[:cert]
        if logstash_forwarder_installed?
          configure_logstash_forwarder! &block
        else
          install_logstash_forwarder!
        end
      else
        raise "Missing key and cert for injection... Expected them to be in: #{LUMBERJACK[:key].dirname}"
      end
    end

    def install_logstash_forwarder!
      needs_package 'git' do
        stream_exec(LUMBERJACK_INSTALL_SCRIPT) do
          configure_logstash_forwarder!
        end
      end
    end

    def configure_logstash_forwarder! &block
      write_logstash_forwarder_certs!
      write_logstash_forwarder_config! &block
      enable_logstash_forwarder!
    end

    def enable_logstash_forwarder!
      scp.upload! LUMBERJACK[:init].to_s, "/etc/init.d/logstash-forwarder"
      ssh.exec!("chmod a+x /etc/init.d/logstash-forwarder")
      log ssh.exec!("update-rc.d logstash-forwarder defaults")
      log ssh.exec!("/etc/init.d/logstash-forwarder stop && /etc/init.d/logstash-forwarder status")
      log ssh.exec!("/etc/init.d/logstash-forwarder start && /etc/init.d/logstash-forwarder status")
    end

    def write_logstash_forwarder_config!
      remote_path = '/etc/logstash-forwarder'
      if file_exists? remote_path
        conf = JSON.parse(ssh.exec!("cat #{remote_path}").strip)
      else
        conf = JSON.parse(LUMBERJACK[:conf].readlines.reject{|l| l.strip.match(/^\#/) }.join)
      end
      conf["network"]["servers"] = [ ENV["LOGSTASH_SERVER"] ]
      yield(conf) if block_given?
      conf["files"].uniq!
      conf = JSON.pretty_generate conf
      remote_write remote_path, conf
    end

    def write_logstash_forwarder_certs!
      dir = "/opt/logstash-forwarder/ssl"
      ssh.exec!("rm -rf #{dir} ; mkdir -p #{dir}")
      scp.upload! LUMBERJACK[:key].to_s, File.join(dir, 'key.pem')
      scp.upload! LUMBERJACK[:cert].to_s, File.join(dir, 'cert.pem')
    end

    def logstash_forwarder_installed?
      file_exists?("/opt/logstash-forwarder/bin/logstash-forwarder") &&
        file_exists?("/etc/init.d/logstash-forwarder")
    end
  end
end
