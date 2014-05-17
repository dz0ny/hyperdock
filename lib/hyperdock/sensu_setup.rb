module Hyperdock
  module SensuSetup

    ##
    # this is called once we are sure docker is installed
    # similar to the docker provisoning, we want to be able to run this
    # at any time -- on a fresh box, partially setup box, or a complete box
    # to install, continue installing, or cleanly upgrade the monitoring system
    # -- at this point we are still connected by SSH as well
    def use_sensu!
      if package_installed? "sensu"
        configure_sensu
      else
        install_sensu { configure_sensu }
      end
    end

    def install_sensu
      log "Installing sensu (client)"
      stream_exec <<-EOF
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get install -y sensu
      EOF
    end

    def configure_sensu
      log "Check version, configure sensu, etc"
      # check version
      # check configuration
    end
  end
end
