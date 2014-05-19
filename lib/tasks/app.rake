namespace :app do
  desc <<-EOF
    Bootstrap or reconfigure Ubuntu LTS (14.04 only) as a Hyperdock App Server
    The following packages will be installed and configured:
      * Sensu (client)
      * Nginx 
      * Unicorn
      * Sidekiq
      * LogstashForwarder
      * SSH
      * UFW

    Usage:
      bin/rake app:provision ip="107.170.11.222" password="bdojosijprci"
  EOF
  task provision: :environment do
    raise "not yet implemented"
    require 'app_provisioner'
    ap = AppProvisioner.new(ENV['ip'], ENV['password'], "webapp")
    ap.provision!
  end
end
