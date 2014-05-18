namespace :monitor do
  desc %{
    Setup or check a Ubuntu LTS host with
      * Sensu
      * RabbitMQ
      * Redis
      * ElasticSearch
      * Nginx
      * LogStash
      * InfluxDB

    Usage:
      bin/rake monitor:provision ip="107.170.11.222" password="bdojosijprci"
  }
  task provision: :environment do
    require 'monitor_provisioner'
    mp = MonitorProvisioner.new(ENV['ip'], ENV['password'], "monitor")
    mp.provision!
    # what it does:
    # * disable ssh password auth
    # * insert a public key for future connections
    #
    # what it doesn't do (yet):
    # * setup sensu
    # * setup logstash
  end
end
