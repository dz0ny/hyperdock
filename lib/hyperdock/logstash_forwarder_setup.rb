module Hyperdock
  module LogstashForwarderSetup
    INIT_SCRIPT = Rails.root.join('config/logstash/forwarder.init')
    INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/logstash-forwarder
      rm -f /etc/logstash-forwarder
      rm -f /etc/init.d/logstash-forwarder
      cd /opt
      git clone https://github.com/elasticsearch/logstash-forwarder.git
      cd logstash-forwarder
      go build
      mkdir bin
      mv logstash-forwarder bin
    EOF
    SSL_KEY = Rails.root.join('config/logstash/ssl/key.pem')
    SSL_CERT = Rails.root.join('config/logstash/ssl/cert.pem')
    LOGSTASH_CONF = Rails.root.join('config/logstash/config.rb')

    def use_logstash_forwarder!
      if logstash_forwarder_installed?
        configure_logstash_forwarder!
      else
        install_logstash_forwarder!
      end
    end

    def install_logstash_forwarder!
      needs_package 'golang'
      needs_package 'git'
      stream_exec(INSTALL_SCRIPT) do
        configure_logstash_forwarder!
      end
    end

    def configure_logstash_forwarder!
      write_logstash_forwarder_certs!
      write_logstash_forwarder_config!
      enable_logstash_forwarder!
    end

    def enable_logstash_forwarder!
      scp.upload! INIT_SCRIPT.to_s, "/etc/init.d/logstash-forwarder"
      ssh.exec!("chmod a+x /etc/init.d/logstash-forwarder")
      log ssh.exec!("update-rc.d logstash-forwarder defaults")
      log ssh.exec!("/etc/init.d/logstash-forwarder stop && /etc/init.d/logstash-forwarder status")
      log ssh.exec!("/etc/init.d/logstash-forwarder start && /etc/init.d/logstash-forwarder status")
    end

    def write_logstash_forwarder_config!
      conf = JSON.parse(LOGSTASH_CONF.readlines.reject{|l| l.strip.match(/^\#/) }.join)
      # make changes here if you want
      # e.g. conf["network"]["servers"] << ALT_LOGSTASH_SERVER
      remote_write '/etc/logstash-forwarder', JSON.pretty_generate(conf)
    end

    def write_logstash_forwarder_certs!
      dir = "/opt/logstash-forwarder/ssl"
      ssh.exec!("rm -rf #{dir} ; mkdir -p #{dir}")
      scp.upload! SSL_KEY.to_s, File.join(dir, 'key.pem')
      scp.upload! SSL_CERT.to_s, File.join(dir, 'cert.pem')
    end

    def logstash_forwarder_installed?
      file_exists?("/opt/logstash-forwarder/bin/logstash-forwarder") &&
        file_exists?("/etc/init.d/logstash-forwarder")
    end
  end
end
