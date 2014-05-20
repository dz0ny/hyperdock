namespace :host do
  desc <<-EOF
    Bootstrap or reconfigure Ubuntu LTS (14.04 or 12.04) as a Hyperdock Host
    The following packages will be installed and configured:
      * Docker FIXME the docker API is not being secured at this time
      * Sensu (client)
      * LogstashForwarder
      * SSH
      * UFW

    Please ensure that you've already provisioned the monitor and that
    all required services are listening on host monitor.hyperdock.io

    Usage:
      bin/rake host:provision name="ny-02" ip="162.243.85.251" password="gpexurxttorr"
      bin/rake host:provision name="ny-01" ip="162.243.161.151" password="vshwpkubhvqz"
      bin/rake host:provision name="sf-01" ip="107.170.249.184" password="bzcwfgknqdcy"
      bin/rake host:provision name="am-01" ip="188.226.227.62" password="vuemvozgsplx"
  EOF
  task provision: :environment do
    require 'host_provisioner'
    hp = HostProvisioner.new(ENV['ip'], ENV['password'], ENV['name'])
    hp.provision!
    # what it does:
    # * disable ssh password auth
    # * insert a public key for future connections
    # * installs docker on a fresh ubuntu LTS host
    # * configures docker to listen on port 5542
    # * install sensu client
    # * configure sensu client
    # * installs logstash forwarder
    # * configures logstash forward system and container logs
    #
    # what it doesn't do (yet):
    # * add host to the database
    # * secure the docker api endpoint
    # * install any sensu checks
    # * expose the docker port on the firewall
    # * expose the docker 49000-49999 range
  end
end
