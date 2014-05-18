namespace :host do
  desc %{
    Setup or check a Ubuntu LTS host with Docker

    Please ensure that you've already provisioned the monitor and that
    all required services are listening on host monitor.hyperdock.io

    Usage:
      bin/rake host:provision name="ny-02" ip="162.243.85.251" password="gpexurxttorr"
      bin/rake host:provision name="ny-01" ip="162.243.161.151" password="vshwpkubhvqz"
      bin/rake host:provision name="sf-01" ip="107.170.249.184" password="bzcwfgknqdcy"
      bin/rake host:provision name="am-01" ip="188.226.227.62" password="vuemvozgsplx"
  }
  task provision: :environment do
    require 'host_provisioner'
    hp = HostProvisioner.new(ENV['ip'], ENV['password'], ENV['name'])
    hp.provision!
    # what it does:
    # * installs docker on a fresh ubuntu LTS host
    # * configures docker to listen on port 5542
    # * install sensu client
    # * configure sensu client
    #
    # what it doesn't do (yet):
    # * disable ssh password auth
    # * insert a public key for future connections
    # * add host to the database
  end
end
