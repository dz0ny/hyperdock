module Hyperdock
  module SensuSetup
    INSTALL_SCRIPT = <<-EOF
      wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
      echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y sensu
    EOF
    SSL_KEY = Rails.root.join('config/sensu/client_keypair/key.pem').to_s
    SSL_CERT = Rails.root.join('config/sensu/client_keypair/cert.pem').to_s

    ##
    # this is called once we are sure docker is installed
    # similar to the docker provisoning, we want to be able to run this
    # at any time -- on a fresh box, partially setup box, or a complete box
    # to install, continue installing, or cleanly upgrade the monitoring system
    # -- at this point we are still connected by SSH as well
    def use_sensu!
      if package_installed? "sensu"
        configure_sensu!
      else
        install_sensu!
      end
    end

    def install_sensu!
      log "Installing sensu (client)"
      stream_exec(INSTALL_SCRIPT) do
        configure_sensu!
      end
    end

    def configure_sensu!
      if sensu_client_certs_installed?

      else
        log "SSL keypair not found: /etc/sensu/ssl/key.pem /etc/sensu/ssl/cert.pem"
        install_sensu_client_certs!
      end
      # Check version, check configuration, make changed if warranted.
      #
      # check version
      # check configuration
    end

    def install_sensu_client_certs!
      log "Creating SSL keypair directory /etc/sensu/ssl"
      ssh.exec!("rm -rf /etc/sensu/ssl ; mkdir -p /etc/sensu/ssl")
      log "Transferring SSL keypair (config/sensu/client_keypair)"
      upload(SSL_KEY, '/etc/sensu/ssl/key.pem')
      upload(SSL_CERT, '/etc/sensu/ssl/cert.pem')
    end

    def sensu_client_certs_installed?
      out = ssh.exec!("ls /etc/sensu/ssl")
      !!(out =~ /key.pem/) && !!(out =~ /cert.pem/)
    end
  end
end
