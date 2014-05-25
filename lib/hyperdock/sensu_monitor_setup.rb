require 'hyperdock/sensu_setup_common'
require 'hyperdock/nginx'

module Hyperdock
  module SensuMonitorSetup
    include SensuSetupCommon
    include Nginx
    MONITOR_DIR = SENSU_CONFIG_DIR.join('monitor')
    CERT_TAR = MONITOR_DIR.join('ssl_certs.tar')
    REDIS_CONF = MONITOR_DIR.join('conf.d/redis.json')
    API_CONF = MONITOR_DIR.join('conf.d/api.json')
    DASHBOARD_CONF = MONITOR_DIR.join('conf.d/dashboard.json')
    RABBITMQ_INSTALL_SCRIPT = <<-EOF
      export DEBIAN_FRONTEND=noninteractive
      apt-get -y install erlang-nox
      wget -q http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -O- | apt-key add -
      echo "deb     http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
      apt-get update > /dev/null
      apt-get install rabbitmq-server
    EOF
    RABBITMQ_CONFIG_STEPS = {
      "Creating SSL directory on RabbitMQ server" => "mkdir -p /etc/rabbitmq/ssl",
      "Copying generated SSL files for RabbitMQ server" => %{
        cp /tmp/ssl_certs/sensu_ca/cacert.pem /etc/rabbitmq/ssl
        cp /tmp/ssl_certs/server/cert.pem /etc/rabbitmq/ssl
        cp /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl
      },
      "Configuring RabbitMQ SSL Listener" => ->(k){
        scp.upload! MONITOR_DIR.join('rabbitmq/rabbitmq.config').to_s, "/etc/rabbitmq/rabbitmq.config"
      },
      "Restarting RabbitMQ ... " => "/etc/init.d/rabbitmq-server restart",
      "Modifying user permissions" => [
        "rabbitmqctl delete_user guest",
        "rabbitmqctl delete_user sensu",
        "rabbitmqctl add_vhost /sensu",
        "rabbitmqctl add_user sensu #{ENV['RABBITMQ_PASSWORD']}",
        %{rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"}
      ]
      # "Enable RabbitMQ web console" => "rabbitmq-plugins enable rabbitmq_management"
    }

    def use_sensu!
      if package_installed? "sensu"
        reconfigure!
      else
        log "Installing Sensu"
        stream_exec(SENSU_INSTALL_SCRIPT) { use_sensu! }
      end
    end

    def reconfigure!
      use_sensu_embedded_ruby!
      generate_new_sensu_certificates
      write_sensu_client_certs! simple_copy: true
      write_rabbit_config!
      write_redis_config!
      write_api_config!
      write_dashboard_config!
      write_client_config!
      setup_nginx_vhost({
        server_name: "sensu.#{@name}.#{ENV['FQDN']}",
        site_name: "sensu",
        template_path: MONITOR_DIR.join('dashboard-nginx.conf')
      })
      setup_rabbitmq
      needs_package 'redis-server' do
        permit_sensu_configs!
        enable_sensu_monitor!
        enable_sensu_client!
        execute_batch("Configure firewall" => {
          "ALLOW ssh port 22" => "ufw allow ssh",
          "DENY redis port 6379" => "ufw deny 6379",
          "ALLOW rabbitmq port 5671" => "ufw allow 5671",
          # TODO terminate API and Dashboard with SSL
          "ALLOW Sensu API port 4567" => "ufw allow 4567",
          "DENY Sensu Dashboard port 8080" => "ufw deny 8080",
          "Enable Firewall" => "yes | ufw enable"
        })
      end
    end

    def write_redis_config!
      conf = JSON.parse REDIS_CONF.read
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/redis.json', conf
    end

    def write_rabbit_config!
      conf = JSON.parse RABBIT_CONF.read
      conf["rabbitmq"]["password"] = ENV["RABBITMQ_PASSWORD"]
      conf["rabbitmq"]["host"] = "localhost"
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/rabbitmq.json', conf
      update_local_env "RABBITMQ_HOST" => @host
    end

    def write_api_config!
      conf = JSON.parse API_CONF.read
      conf["api"]["user"] = ENV["SENSU_API_USER"]
      conf["api"]["password"] = ENV["SENSU_API_PASSWORD"]
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/api.json', conf
    end

    def write_dashboard_config!
      conf = JSON.parse DASHBOARD_CONF.read
      conf["dashboard"]["user"] = ENV["SENSU_DASHBOARD_USER"]
      conf["dashboard"]["password"] = ENV["SENSU_DASHBOARD_PASSWORD"]
      conf = JSON.pretty_generate(conf)
      remote_write '/etc/sensu/conf.d/dashboard.json', conf
    end

    def setup_rabbitmq
      if package_installed? "rabbitmq-server"
        execute_batch RABBITMQ_CONFIG_STEPS
      else
        log "Installing rabbitmq-server"
        stream_exec(RABBITMQ_INSTALL_SCRIPT) { setup_rabbitmq }
      end
    end

    def generate_new_sensu_certificates
      ssh.exec! "rm -rf /tmp/ssl_cert*"
      log "Uploading SSL certificate generator"
      scp.upload! CERT_TAR.to_s, "/tmp"
      log "Extracting ..."
      log ssh.exec! "cd /tmp && tar -xvf ssl_certs.tar"
      log ssh.exec! "cd /tmp/ssl_certs && ./ssl_certs.sh generate 2>/dev/null"
      replace_local_sensu_certs
    end

    def replace_local_sensu_certs
      # TODO maybe later you want to make this a choice?
      log_after "You have generated new certs!.".yellow
      dir = SENSU[:key].dirname
      FileUtils.mkdir(dir) unless dir.exist?
      scp.download!("/tmp/ssl_certs/client/cert.pem", SENSU[:cert].to_s)
      log_after "New SSL cert downloaded to #{SENSU[:cert]}".yellow
      scp.download!("/tmp/ssl_certs/client/key.pem", SENSU[:key].to_s)
      log_after "New SSL private key downloaded to #{SENSU[:key]}".yellow
      log_after "Make sure to run the host provisioner again on all hosts to setup the new certs".yellow
    end
  end
end
