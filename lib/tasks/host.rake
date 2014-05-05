namespace :host do
  desc %{
    Add a new Ubuntu 12.04 LTS host to the system.
    Docker will be setup automatically.
    The host will not be tied to a region.
    Usage:
      bin/rake host:add host="198.199.112.194" password="awefawef"
  }
  task add: :environment do
    require 'host_provisioner'
    hp = HostProvisioner.new(ENV['host'], ENV['password'])
    hp.provision!
    # stuff still left to do:
    # disable password auth
    # insert hyperdock's public key for future connections
    # add host to database
    binding.pry
  end
end
