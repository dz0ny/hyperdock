module Hyperdock
  module SensuSetupCommon
    INSTALL_SCRIPT = <<-EOF
      wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
      echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
      apt-get install -y sensu
    EOF
    SENSU_CONFIG_DIR = Rails.root.join('config/sensu')
    CLIENT_DIR = SENSU_CONFIG_DIR.join('client')
    CLIENT_CONF = CLIENT_DIR.join('client.json')
    SSL_KEY = CLIENT_DIR.join('ssl/key.pem')
    SSL_CERT = CLIENT_DIR.join('ssl/cert.pem')
    RABBIT_CONF = CLIENT_DIR.join('conf.d/rabbitmq.json')
    MONITOR_DIR = SENSU_CONFIG_DIR.join('monitor')
    REDIS_CONF = MONITOR_DIR.join('conf.d/redis.json')

    def use_sensu_embedded_ruby!
      remote_write '/etc/default/sensu', "EMBEDDED_RUBY=true"
    end

    def write_sensu_client_certs!
      ssh.exec!("rm -rf /etc/sensu/ssl ; mkdir -p /etc/sensu/ssl")
      scp.upload! SSL_KEY.to_s, '/etc/sensu/ssl/key.pem'
      scp.upload! SSL_CERT.to_s, '/etc/sensu/ssl/cert.pem'
    end

    def write_rabbit_config!
      conf = JSON.parse RABBIT_CONF.read
      conf["rabbitmq"]["password"] = ENV["RABBITMQ_PASSWORD"]
      conf["rabbitmq"]["host"] = ENV["RABBITMQ_HOST"]
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/rabbitmq.json', conf
    end
  end
end
