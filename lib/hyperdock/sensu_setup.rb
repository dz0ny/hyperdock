module Hyperdock
  module SensuSetup
    INSTALL_SCRIPT = <<-EOF
      wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
      echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y sensu
    EOF
    SSL_KEY = Rails.root.join('config/sensu/client/ssl/key.pem')
    SSL_CERT = Rails.root.join('config/sensu/client/ssl/cert.pem')
    RABBIT_CONF = Rails.root.join('config/sensu/client/conf.d/rabbitmq.json')
    CLIENT_CONF = Rails.root.join('config/sensu/client.json')

    ##
    # this is called once we are sure docker is installed
    # similar to the docker provisoning, we want to be able to run this
    # at any time -- on a fresh box, partially setup box, or a complete box
    # to install, continue installing, or cleanly upgrade the monitoring system
    # -- at this point we are still connected by SSH as well
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
      log ssh.exec!("chown -R sensu:sensu /etc/sensu")
      log ssh.exec!("update-rc.d sensu-client defaults")
      log ssh.exec!("/etc/init.d/sensu-client stop")
      log ssh.exec!("/etc/init.d/sensu-client start")
    end

    def use_sensu_embedded_ruby!
      remote_write '/etc/default/sensu', "EMBEDDED_RUBY=true"
    end
    
    def write_rabbit_config!
      conf = JSON.parse RABBIT_CONF.read
      # change stuff as needed via conf["rabbitmq"] ... e.g. insert password via envvars
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
