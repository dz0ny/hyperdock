module Hyperdock
  module Nginx
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
        conf = conf.gsub('SSL_CERT', ssl[:ssl_cert])
        conf = conf.gsub('SSL_KEY', ssl[:ssl_key])
      end
      remote_write site_available, conf
      ssh.exec! "ln -s #{site_available} #{site_enabled}"
      ssh.exec! "service nginx reload"
      log_after "Be sure to add DNS record: "+"#{opts[:server_name]} to #{@host}".yellow
    end
  end
end
