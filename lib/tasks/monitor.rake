namespace :monitor do
  desc <<-EOF
    Bootstrap or reconfigure Ubuntu LTS (14.04 only) as the Hyperdock Monitor
    The following packages will be installed and configured:
      * Sensu (monitor and client)
      * RabbitMQ
      * Redis
      * Nginx 
      * Kibana 
      * ElasticSearch
      * Logstash
      * LogstashForwarder
      * SSH
      * UFW

    Usage:
      bin/rake monitor:provision id=5
  EOF
  task provision: :environment do
    require 'monitor_provisioner'
    record = Host.find(ENV['id'])
    ENV["RABBITMQ_HOST"] = record.monitor.rabbitmq_host
    ENV["LOGSTASH_SERVER"] = record.monitor.logstash_server
    mp = MonitorProvisioner.new(record.ip_address, ENV['password'], record.name)
    mp.auth = record.ssh_identity
    mp.after_configured_passwordless_login { record.ssh_identity = mp.auth }
    mp.on_update_env {|key, value| record.update_attribute(key, value) }
    mp.set_monitor { record.monitor }
    mp.provision!
    # what it does:
    # * disable ssh password auth
    # * insert a public key for future connections
    # * setup sensu
    # * setup logstash
    # * installs logstash forwarder
    # * configures logstash forward system and sensu logs
    #
    # what it doesn't do (yet):
    # * InfluxDB
  end

  desc <<-EOF
    Open an SSH connection into a monitor

    Usage: 
      $(bin/rake monitor:ssh id=6)
  EOF
  task ssh: :environment do
    require 'monitor_provisioner'
    if ENV['id']
      record = Host.find(ENV['id'])
      puts "ssh -i #{record.ssh_identity[:private_key]} root@#{record.ip_address}"
    end
  end
end
