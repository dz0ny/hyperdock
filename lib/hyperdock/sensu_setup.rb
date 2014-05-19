require 'hyperdock/sensu_setup_common'

module Hyperdock
  module SensuSetup
    include SensuSetupCommon
    RABBIT_CONF = CLIENT_DIR.join('conf.d/rabbitmq.json')
    CLIENT_CONF = SENSU_CONFIG_DIR.join('client.json')

    def use_sensu!
      if package_installed? "sensu"
        configure_sensu_client!
      else
        install_sensu!
      end
    end

    def install_sensu!
      log "Installing sensu (client)"
      stream_exec(INSTALL_SCRIPT) do
        configure_sensu_client!
      end
    end

    def configure_sensu_client!
      write_sensu_client_certs!
      write_rabbit_config!
      write_client_config!
      use_sensu_embedded_ruby!
      enable_sensu_client!
    end

    def enable_sensu_client!
      ssh.exec!("chown -R sensu:sensu /etc/sensu")
      log ssh.exec!("update-rc.d sensu-client defaults")
      log ssh.exec!("/etc/init.d/sensu-client stop")
      log ssh.exec!("/etc/init.d/sensu-client start")
    end

    def write_rabbit_config!
      conf = JSON.parse RABBIT_CONF.read
      conf["rabbitmq"]["password"] = ENV["RABBITMQ_PASSWORD"]
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/rabbitmq.json', conf
    end

    def write_client_config!
      conf = JSON.parse CLIENT_CONF.read
      conf["client"]["name"] = @name
      conf["client"]["address"] = @host
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/client.json', conf
    end

    def write_sensu_client_certs!
      ssh.exec!("rm -rf /etc/sensu/ssl ; mkdir -p /etc/sensu/ssl")
      scp.upload! SSL_KEY.to_s, '/etc/sensu/ssl/key.pem'
      scp.upload! SSL_CERT.to_s, '/etc/sensu/ssl/cert.pem'
    end

    def sensu_client_certs_installed?
      out = ssh.exec!("ls /etc/sensu/ssl")
      !!(out =~ /key.pem/) && !!(out =~ /cert.pem/)
    end
  end
end
