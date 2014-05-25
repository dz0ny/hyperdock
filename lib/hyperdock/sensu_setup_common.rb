module Hyperdock
  module SensuSetupCommon
    SENSU_INSTALL_SCRIPT = <<-EOF
      wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
      echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
      apt-get update > /dev/null
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y sensu
    EOF
    SENSU_CONFIG_DIR = Rails.root.join('config/sensu')
    CLIENT_DIR = SENSU_CONFIG_DIR.join('client')
    CLIENT_CONF = CLIENT_DIR.join('conf.d/client.json')
    SENSU = {
      key: CLIENT_DIR.join('ssl/key.pem'),
      cert: CLIENT_DIR.join('ssl/cert.pem')
    }
    RABBIT_CONF = CLIENT_DIR.join('conf.d/rabbitmq.json')

    def use_sensu_embedded_ruby!
      remote_write '/etc/default/sensu', "EMBEDDED_RUBY=true"
    end

    def write_sensu_client_certs! opts={}
      ssh.exec!("rm -rf /etc/sensu/ssl ; mkdir -p /etc/sensu/ssl")
      if opts[:simple_copy]
        ssh.exec!("cat /tmp/ssl_certs/client/cert.pem > /etc/sensu/ssl/cert.pem")
        ssh.exec!("cat /tmp/ssl_certs/client/key.pem > /etc/sensu/ssl/key.pem")
      elsif self.respond_to? :monitor
        log "Writing sensu keys from monitor #{monitor.name}"
        remote_write '/etc/sensu/ssl/key.pem', self.monitor.sensu_key
        remote_write '/etc/sensu/ssl/cert.pem', self.monitor.sensu_cert
      else
        scp.upload! SENSU[:key].to_s, '/etc/sensu/ssl/key.pem'
        scp.upload! SENSU[:cert].to_s, '/etc/sensu/ssl/cert.pem'
      end
    end

    def write_rabbit_config!
      conf = JSON.parse RABBIT_CONF.read
      conf["rabbitmq"]["password"] = ENV["RABBITMQ_PASSWORD"]
      conf["rabbitmq"]["host"] = ENV["RABBITMQ_HOST"]
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

    def permit_sensu_configs!
      ssh.exec!("chown -R sensu:sensu /etc/sensu")
    end

    def enable_sensu_client!
      enable_initd_service "sensu-client"
    end

    def enable_sensu_monitor!
      ['server', 'api', 'dashboard'].each do |name|
        enable_initd_service "sensu-#{name}"
      end
    end
  end
end
