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
    RABBITMQ_POSTINSTALL_SCRIPT = {
      "Creating SSL directory on RabbitMQ server" => "mkdir -p /etc/rabbitmq/ssl",
      "Copying generated SSL files for RabbitMQ server" => %{
        cp /tmp/ssl_certs/sensu_ca/cacert.pem /etc/rabbitmq/ssl
        cp /tmp/ssl_certs/server/cert.pem /etc/rabbitmq/ssl
        cp /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl
      },
      "Configuring RabbitMQ SSL Listener" => ->(k){
        scp.upload! MONITOR_DIR.join('rabbitmq/rabbitmq.config').to_s, "/etc/rabbitmq/rabbitmq.config"
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
      generate_new_certificates
      setup_rabbitmq
    end

    def setup_rabbitmq
      if package_installed? "rabbitmq-server"
        execute_scripts_hash RABBITMQ_POSTINSTALL_SCRIPT, self
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
      ssh.exec! "cd /tmp && tar -xvf ssl_certs.tar"
      ssh.exec! "cd /tmp/ssl_certs && ./ssl_certs.sh generate 2>/dev/null"
    end
  end
end
