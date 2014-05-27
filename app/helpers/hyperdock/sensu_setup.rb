require 'hyperdock/sensu_setup_common'

module Hyperdock
  module SensuSetup
    include SensuSetupCommon

    def use_sensu!
      if SENSU[:key].exist? && SENSU[:cert].exist?
        if package_installed? "sensu"
          configure_sensu_client!
        else
          install_sensu!
        end
      else
        raise "Missing key and cert for injection... Expected them to be in: #{SENSU[:key].dirname}"
      end
    end

    def install_sensu!
      log "Installing sensu (client)"
      stream_exec(SENSU_INSTALL_SCRIPT) do
        configure_sensu_client!
      end
    end

    def configure_sensu_client!
      write_sensu_client_certs!
      write_rabbit_config!
      write_client_config! 
      use_sensu_embedded_ruby!
      permit_sensu_configs!
      enable_sensu_client!
    end
  end
end
