require 'ssh_wrapper'
require 'hyperdock/sensu_monitor_setup'
require 'hyperdock/logstash_setup'
require 'hyperdock/logstash_forwarder_setup'

class MonitorProvisioner < SshWrapper
  include Hyperdock::SensuMonitorSetup
  include Hyperdock::LogstashSetup
  include Hyperdock::LogstashForwarderSetup

  def provision!
    start( version: '14.04' ) do
      #use_sensu!
      #use_logstash!
      use_logstash_forwarder! do |config|
        # Collect supervisor logs
        config["files"] << {
          "paths" => [ "/var/log/supervisor/*.log" ],
          "fields"=> { "type"=> "supervisor" }
        }

        # Collect sensu logs
        config["files"] << {
          "paths" => [ "/var/log/sensu/sensu-*.log" ],
          "fields"=> { "type"=> "sensu" }
        }
      end
    end
  end
end
