require 'hyperdock/sensu_setup_common'

module Hyperdock
  module SensuMonitorSetup
    include SensuSetupCommon
    DIR = SENSU_CONFIG_DIR.join('monitor')
    CERT_TAR = DIR.join('ssl_certs.tar')

    def use_sensu!
      if package_installed? "sensu"
        configure_sensu_monitor!
      else
        install_sensu!
      end
    end

    def install_sensu!
      log "Installing sensu (monitor)"
      stream_exec(INSTALL_SCRIPT) do
        configure_sensu_monitor!
      end
    end

    def configure_sensu_monitor!
      generate_new_certificates
    end

    def generate_new_certificates
      ssh.exec!("rm -rf /tmp/ssl_cert*")
      log "Uploading SSL certificate generator"
      scp.upload! CERT_TAR.to_s, "/tmp"
      script = <<-EOF
        cd /tmp
        tar -xvf ssl_certs.tar
        cd ssl_certs
        ./ssl_certs.sh generate 2>/dev/null
      EOF
      stream_exec(script)
    end

  end
end
