require 'hyperdock/ssh/wrapper'
require 'hyperdock/sensu_monitor_setup'
require 'hyperdock/logstash_setup'

class MonitorProvisioner < Hyperdock::SSH::Wrapper
  include Hyperdock::SensuMonitorSetup
  include Hyperdock::LogstashSetup

  def provision!
    start( version: '14.04' ) do
      use_sensu!
      use_logstash!
      use_logstash_forwarder! do |config|
        # Collect supervisor logs
        config["files"] << {
          "paths" => [ "/var/log/supervisor/*.log" ],
          "fields"=> { "type"=> "supervisor" }
        }

        # Collect nginx logs
        config["files"] << {
          "paths" => [ "/var/log/nginx/*.log" ],
          "fields"=> { "type"=> "nginx" }
        }

        # Collect sensu logs
        config["files"] << {
          "paths" => [ "/var/log/sensu/sensu-*.log" ],
          "fields"=> { "type"=> "sensu" }
        }
      end
      execute_batch("Configure firewall" => {
        "DENY redis port 6379" => "ufw deny 6379",
        "ALLOW rabbitmq port 5671" => "ufw allow 5671",
        "ALLOW Sensu API port 4567" => "ufw allow 4567", # TODO terminate sensu API with SSL
        "DENY Sensu Dashboard port 8080" => "ufw deny 8080", # make sure we terminated this with SSL correctly
        "DENY elasticsearch port 9200" => "ufw deny 9200",
        "ALLOW lumberjack port 5043" => "ufw allow 5043",
        "ALLOW ssh port 22" => "ufw allow ssh",
        "ALLOW nginx port 80" => "ufw allow 80",
        "ALLOW nginx port 443" => "ufw allow 443",
        "Enable firewall" => "yes | ufw enable"
      })
    end
  end
end
