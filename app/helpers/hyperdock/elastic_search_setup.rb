module Hyperdock
  module ElasticSearchSetup
    ELASTICSEARCH_VERSION = "1.1.1"
    ELASTICSEARCH_HOME = "/opt/elasticsearch-#{ELASTICSEARCH_VERSION}"
    ELASTICSEARCH_BIN = File.join(ELASTICSEARCH_HOME, 'bin/elasticsearch')
    ELASTICSEARCH_CONF = File.join(ELASTICSEARCH_HOME, 'config/elasticsearch.yml')

    ELASTICSEARCH_INSTALL_SCRIPT = <<-EOF
      rm -rf /opt/elasticsearc* 
      cd /opt
      echo "ElasticSearch Downloading ..."
      wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{ELASTICSEARCH_VERSION}.tar.gz 2>/dev/null
      echo "ElasticSearch Extracting ..."
      tar -zxvf elasticsearch-#{ELASTICSEARCH_VERSION}.tar.gz > /dev/null
      rm -f elasticsearch-#{ELASTICSEARCH_VERSION}.tar.gz
    EOF


    def use_elasticsearch!
      if elasticsearch_installed?
        reconfigure_elasticsearch!
      else
        log "Installing ElasticSearch"
        script = "#{ELASTICSEARCH_INSTALL_SCRIPT}"
        stream_exec(script) { use_elasticsearch! }
      end
    end

    def reconfigure_elasticsearch!
      path = Rails.root.join('config/elasticsearch/elasticsearch.yml')
      contents = path.read.gsub('ELASTICSEARCH_CLUSTER_NAME', @name)
      remote_write ELASTICSEARCH_CONF, contents
    end

    def elasticsearch_installed?
      file_exists?(ELASTICSEARCH_BIN)
    end
  end
end
