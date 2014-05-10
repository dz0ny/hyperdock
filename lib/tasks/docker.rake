namespace :docker do
  desc %{
    Setup or check a Ubuntu 12.04 LTS host with Docker

    Usage:
      bin/rake docker:setup host="198.199.112.194" password="awefawef"
  }
  task setup: :environment do
    require 'docker/host_provisioner'
    hp = Docker::HostProvisioner.new(ENV['host'], ENV['password'])
    hp.provision!
    # stuff still left to do:
    # disable password auth
    # insert hyperdock's public key for future connections
    # add host to database
  end
end
