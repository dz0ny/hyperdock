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
      bin/rake monitor:provision ip="107.170.11.222" password="bdojosijprci"
  EOF
  task provision: :environment do
    require 'monitor_provisioner'
    mp = MonitorProvisioner.new(ENV['ip'], ENV['password'], "monitor")
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
end
