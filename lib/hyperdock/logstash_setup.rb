module Hyperdock
  module LogstashSetup
    VERSION = "1.4.1"
    INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/logstas* /usr/local/bin/logstas*

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -yq openjdk-7-jre-headless supervisor
      cd /opt
      echo "Downloading logstash ..."
      wget https://download.elasticsearch.org/logstash/logstash/logstash-#{VERSION}.tar.gz 2>/dev/null
      tar -zxvf logstash-#{VERSION}.tar.gz > /dev/null
      echo "Symlinking ..."
      ln -s /opt/logstash-#{VERSION}/bin/logstash /usr/local/bin/logstash
      ln -s /opt/logstash-#{VERSION}/bin/logstash.lib.sh /usr/local/bin/logstash.lib.sh
      rm -f logstash-#{VERSION}.tar.gz


    EOF

    FIREWALL = {
      "Configure firewall" => {
        "ALLOW ssh port 22" => "ufw allow ssh",
        "ALLOW elasticsearch port 9200" => "ufw allow 9200",
        "ALLOW nginx port 80" => "ufw allow 80",
        "ALLOW lumberjack port 5043" => "ufw allow 5043",
        "Enable Firewall" => "yes | ufw enable"
      }
    }

    def use_logstash!
      if logstash_installed?
        reconfigure!
      else
        log "Installing Logstash"
        stream_exec(INSTALL_SCRIPT) { exit ; use_logstash! }
      end
    end

    def reconfigure!
      #write_logstash_certs!
      #write_logstash_config!
      #enable_logstash!
    end

    def logstash_installed?
      file_exists?("/usr/local/bin/logstash")
    end
  end
end
