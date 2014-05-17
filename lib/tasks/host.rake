namespace :host do
  desc %{
    Setup or check a Ubuntu LTS host with Docker

    Usage:
      bin/rake docker:setup host="198.199.112.194" password="awefawef"
  }
  task provision: :environment do
    require 'host_provisioner'
    hp = HostProvisioner.new(ENV['host'], ENV['password'])
    hp.provision!
    # what it does:
    # * installs docker on a fresh ubuntu LTS host
    # * configures docker to listen on port 5542
    #
    # what it doesn't do (yet):
    # * install sensu client
    # * configure sensu client
    # * disable ssh password auth
    # * insert a public key for future connections
    # * add host to the database
  end
end
