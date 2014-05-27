require 'hyperdock/nginx'

module Hyperdock
  module Kibana
    include Nginx
    KIBANA_INSTALL_SCRIPT = <<-EOF
      rm -rf /usr/share/kibana3
      cd /usr/share
      wget -q http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip
      unzip kibana-latest.zip
      mv kibana-latest kibana3
      rm -f kibana-latest.zip
    EOF

    def use_kibana
      if file_exists? '/usr/share/kibana3'
        remote_write '/usr/share/kibana3/config.js', Rails.root.join('config/logstash/kibana.config.json').read
        ssh.exec! "chmod 644 /usr/share/kibana3/config.js"
        log ssh.exec! %{echo "#{ENV['KIBANA_PASSWORD']}" | htpasswd -ci /etc/nginx/conf.d/kibana.htpasswd #{ENV['KIBANA_USERNAME']}}
        setup_nginx_vhost({
          server_name: "kibana.#{@name}.#{ENV['FQDN']}",
          site_name: "kibana",
          template_path: Rails.root.join('config/logstash/kibana-nginx.conf')
        })
      else
        needs_package('nginx') do
          stream_exec(KIBANA_INSTALL_SCRIPT) { use_kibana }
        end
      end
    end
  end
end
