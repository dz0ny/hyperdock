require 'hyperdock/sensu_setup_common'

module Hyperdock
  module SensuSetup
    include SensuSetupCommon

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

    def write_client_config!
      conf = JSON.parse CLIENT_CONF.read
      conf["client"]["name"] = @name
      conf["client"]["address"] = @host
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/client.json', conf
    end
  end
end
