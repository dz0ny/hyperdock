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
      bin/rake host:provision id=5
  EOF
  task provision: :environment do
    require 'host_provisioner'
    record = Host.find(ENV['id'])
    ENV["RABBITMQ_HOST"] = record.monitor.rabbitmq_host
    ENV["LOGSTASH_SERVER"] = record.monitor.logstash_server
    hp = HostProvisioner.new(record.ip_address, ENV['password'], record.name)
    hp.auth = record.ssh_identity
    hp.after_configured_passwordless_login { record.ssh_identity = mp.auth }
    hp.on_update_env {|key, value| record.update_attribute(key, value) }
    hp.set_monitor { record.monitor }
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
