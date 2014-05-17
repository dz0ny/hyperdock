namespace :host do
  desc %{
    Setup or check a Ubuntu LTS host with Docker

    Usage:
      bin/rake host:provision name="ny-02" ip="162.243.85.251" password="gpexurxttorr"
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
