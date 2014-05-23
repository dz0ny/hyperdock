require 'hyperdock/logstash_forwarder_setup'
require 'hyperdock/elastic_search_setup'
require 'hyperdock/kibana'

module Hyperdock
  module LogstashSetup
    include Hyperdock::LogstashForwarderSetup
    include Hyperdock::ElasticSearchSetup
    include Hyperdock::Kibana

    LOGSTASH_VERSION = "1.4.1"
    LOGSTASH_BIN = "/opt/logstash-#{LOGSTASH_VERSION}/bin/logstash"

    LOGSTASH_INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/logstas* 
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -yq openjdk-7-jre-headless supervisor unzip nginx apache2-utils
      cd /opt
      echo "Logstash Downloading ..."
      wget https://download.elasticsearch.org/logstash/logstash/logstash-#{LOGSTASH_VERSION}.tar.gz 2>/dev/null
      echo "Logstash Extracting ..."
      tar -zxvf logstash-#{LOGSTASH_VERSION}.tar.gz > /dev/null
      rm -f logstash-#{LOGSTASH_VERSION}.tar.gz
    EOF

    def use_logstash!
      if logstash_installed?
        reconfigure_logstash!
        use_elasticsearch!
      else
        log "Installing Logstash"
        script = "#{LOGSTASH_INSTALL_SCRIPT}"
        stream_exec(script) { use_logstash! }
      end
    end


    def write_logstash_config
      path = Rails.root.join('config/logstash/config')
      contents = path.read.gsub('ELASTICSEARCH_HOST', '127.0.0.1').
                           gsub('ELASTICSEARCH_CLUSTER', @name)
      remote_write '/etc/logstash', contents
    end

    def reconfigure_logstash!
      generate_new_logstash_certificates
      write_logstash_config
      setup_logstash_supervisor
      use_kibana
      execute_batch("Configure firewall" => {
        "ALLOW ssh port 22" => "ufw allow ssh",
        "DENY elasticsearch port 9200" => "ufw deny 9200",
        "ALLOW nginx port 80" => "ufw allow 80",
        "ALLOW lumberjack port 5043" => "ufw allow 5043",
        "Enable Firewall" => "yes | ufw enable"
      })
      update_local_env "LOGSTASH_SERVER" => "#{@host}:5043"
    end

    def logstash_installed?
      file_exists? LOGSTASH_BIN
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
      log ssh.exec! "supervisorctl stop all"
      log ssh.exec! "service supervisor restart"
    end
  end
end
