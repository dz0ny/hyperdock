require 'hyperdock/sensu_setup_common'

module Hyperdock
  module SensuMonitorSetup
    include SensuSetupCommon
    MONITOR_DIR = SENSU_CONFIG_DIR.join('monitor')
    CERT_TAR = MONITOR_DIR.join('ssl_certs.tar')
    RABBITMQ_INSTALL_SCRIPT = <<-EOF
      apt-get -y install erlang-nox
      wget -q http://www.rabbitmq.com/rabbitmq-signing-key-public.asc -O- | apt-key add -
      echo "deb     http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list
      apt-get update
      export DEBIAN_FRONTEND=noninteractive
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
        "rabbitmqctl add_user sensu mypass",
        %{rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"}
      ]
      # "Enable RabbitMQ web console" => "rabbitmq-plugins enable rabbitmq_management"
    }
    FIREWALL = {
      "Configure firewall" => {
        "Allow ssh port 22" => "ufw allow ssh",
        "Allow redis port 6379" => "ufw deny 6379",
        "Allow rabbitmq port 5671" => "ufw deny 5671",
        "Enable Firewall" => "yes | ufw enable"
      }
    }

    def use_sensu!
      if package_installed? "sensu"
        reconfigure!
      else
        log "Installing sensu (monitor)"
        stream_exec(INSTALL_SCRIPT) do
          configure_sensu_monitor!
        end
      end
    end

    def reconfigure!
      use_sensu_embedded_ruby!
      generate_new_certificates
      setup_rabbitmq
      needs_package 'redis-server' do
        execute_batch FIREWALL
      end
    end

    def setup_rabbitmq
      if package_installed? "rabbitmq-server"
        execute_batch RABBITMQ_CONFIG_STEPS
      else
        log "Installing rabbitmq-server"
        stream_exec(RABBITMQ_INSTALL_SCRIPT) { setup_rabbitmq }
      end
    end

    def generate_new_certificates
      ssh.exec! "rm -rf /tmp/ssl_cert*"
      log "Uploading SSL certificate generator"
      scp.upload! CERT_TAR.to_s, "/tmp"
      log "Extracting ..."
      log ssh.exec! "cd /tmp && tar -xvf ssl_certs.tar"
      log ssh.exec! "cd /tmp/ssl_certs && ./ssl_certs.sh generate 2>/dev/null"
      replace_local_certs
    end

    def replace_local_certs
      # TODO maybe later you want to make this a choice?
      log "You have generated new certs! I will download the client certs now.".yellow
      scp.download!("/tmp/ssl_certs/client/cert.pem", SSL_CERT.to_s)
      log "Updated #{SSL_CERT}"
      scp.download!("/tmp/ssl_certs/client/key.pem", SSL_KEY.to_s)
      log "Updated #{SSL_KEY}"
      log "Make sure to run the host provisioner again on all hosts to use the new keys!".yellow
    end
  end
end
