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
      bin/rake monitor:provision ip="107.170.98.132" password="tsbkisqafcfs"
  }
  task provision: :environment do
    require 'monitor_provisioner'
    mp = MonitorProvisioner.new(ENV['ip'], ENV['password'], "monitor")
    mp.provision!
    # what it does:
    #
    # what it doesn't do (yet):
    # * disable ssh password auth
    # * insert a public key for future connections
  end
end
