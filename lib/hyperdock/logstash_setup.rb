require 'hyperdock/logstash_forwarder_setup'

module Hyperdock
  module LogstashSetup
    include Hyperdock::LogstashForwarderSetup

    LOGSTASH_VERSION = "1.4.1"
    LOGSTASH_BIN = "/opt/logstash-#{LOGSTASH_VERSION}/bin/logstash"

    ELASTICSEARCH_VERSION = "1.1.1"
    ELASTICSEARCH_BIN = "/opt/elasticsearch-#{ELASTICSEARCH_VERSION}/bin/elasticsearch"

    ELASTICSEARCH_INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/elasticsearc* 
      cd /opt
      echo "ElasticSearch Downloading ..."
      wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{ELASTICSEARCH_VERSION}.tar.gz 2>/dev/null
      echo "ElasticSearch Extracting ..."
      tar -zxvf elasticsearch-#{ELASTICSEARCH_VERSION}.tar.gz > /dev/null
      rm -f elasticsearch-#{ELASTICSEARCH_VERSION}.tar.gz
    EOF

    LOGSTASH_INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/logstas* 
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -yq openjdk-7-jre-headless supervisor
      cd /opt
      echo "Logstash Downloading ..."
      wget https://download.elasticsearch.org/logstash/logstash/logstash-#{LOGSTASH_VERSION}.tar.gz 2>/dev/null
      echo "Logstash Extracting ..."
      tar -zxvf logstash-#{LOGSTASH_VERSION}.tar.gz > /dev/null
      rm -f logstash-#{LOGSTASH_VERSION}.tar.gz
    EOF

    def use_logstash!
      if logstash_installed? && elasticsearch_installed?
        reconfigure_logstash!
      else
        log "Installing Logstash & ElasticSearch"
        script = "#{LOGSTASH_INSTALL_SCRIPT}\n#{ELASTICSEARCH_INSTALL_SCRIPT}"
        stream_exec(script) { use_logstash! }
      end
    end

    def reconfigure_logstash!
      generate_new_logstash_certificates
      remote_write '/etc/logstash', Rails.root.join('config/logstash/config').to_s
      setup_logstash_supervisor
      #execute_batch("Configure firewall" => {
      #  "ALLOW ssh port 22" => "ufw allow ssh",
      #  "ALLOW elasticsearch port 9200" => "ufw allow 9200",
      #  "ALLOW nginx port 80" => "ufw allow 80",
      #  "ALLOW lumberjack port 5043" => "ufw allow 5043",
      #  "Enable Firewall" => "yes | ufw enable"
      #})
    end

    def logstash_installed?
      file_exists? LOGSTASH_BIN
    end

    def elasticsearch_installed?
      file_exists? ELASTICSEARCH_BIN
    end

    def generate_new_logstash_certificates
      dir = "/var/ssl/logstash"
      remote = { key: "#{dir}/key.pem", cert: "#{dir}/cert.pem" }
      ssh.exec! "mkdir -p #{dir}"
      ssh.exec! "openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout #{remote[:key]} -out #{remote[:cert]}"
      # TODO maybe later you want to make this a choice?
      log log_after "You have generated new certs!.".yellow
      dir = LUMBERJACK[:key].dirname
      FileUtils.mkdir(dir) unless dir.exist?
      scp.download!(remote[:cert], LUMBERJACK[:cert].to_s)
      log log_after "New SSL cert downloaded to #{LUMBERJACK[:cert]}".yellow
      scp.download!(remote[:key], LUMBERJACK[:key])
      log log_after "New SSL private key downloaded to #{LUMBERJACK[:key]}".yellow
      log log_after "Make sure to run the host provisioner again on all hosts to setup the new certs".yellow
    end

    def setup_logstash_supervisor
      confs = Rails.root.join('config/supervisor/monitor')
      es_conf = confs.join('elasticsearch.conf').read.gsub('ELASTICSEARCH_BIN', ELASTICSEARCH_BIN)
      ls_conf = confs.join('logstash.conf').read.gsub('LOGSTASH_BIN', LOGSTASH_BIN)
      remote_write '/etc/supervisor/conf.d/elasticsearch.conf', es_conf
      remote_write '/etc/supervisor/conf.d/logstash.conf', ls_conf
    end
  end
end
