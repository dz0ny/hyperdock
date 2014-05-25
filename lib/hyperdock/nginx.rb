require 'hyperdock/dns'

module Hyperdock
  module Nginx
    include DNS
    
    NGINX_BUCKET_SIZE_CONF = '/etc/nginx/conf.d/server_names_bucket_size.conf'

    def setup_nginx_vhost opts
      ssh.exec! 'rm -f /etc/nginx/sites-enabled/default'
      site_available = "/etc/nginx/sites-available/#{opts[:site_name]}"
      site_enabled = "/etc/nginx/sites-enabled/#{opts[:site_name]}"
      ssh.exec! "rm -f #{site_available}"
      ssh.exec! "rm -f #{site_enabled}"
      conf = Pathname.new(opts[:template_path]).read
      conf = conf.gsub('SERVER_NAME', opts[:server_name])
      unless opts[:insecure]
        ssl = generate_certificate(cert: "/var/ssl/nginx/cert.pem", key: "/var/ssl/nginx/key.pem")
        conf = conf.gsub('SSL_CERT', ssl[:cert])
        conf = conf.gsub('SSL_KEY', ssl[:key])
      end
      remote_write site_available, conf
      ssh.exec! "ln -s #{site_available} #{site_enabled}"
      ssh.exec! "service nginx reload"
      add_dns_record(:A, opts[:server_name], @host)
      log_after("Created site https://#{opts[:server_name]}")
      unless file_exists? NGINX_BUCKET_SIZE_CONF
        remote_write NGINX_BUCKET_SIZE_CONF, "server_names_hash_bucket_size 64;"
      end
    end
  end
end
