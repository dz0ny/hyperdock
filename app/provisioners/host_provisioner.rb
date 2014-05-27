require 'hyperdock/ssh/wrapper'
require 'hyperdock/sensu_setup'
require 'hyperdock/docker_setup'
require 'hyperdock/logstash_forwarder_setup'

class HostProvisioner < Hyperdock::SSH::Wrapper
  include Hyperdock::SensuSetup
  include Hyperdock::DockerSetup
  include Hyperdock::LogstashForwarderSetup

  def provision!
    start( version: '14.04' ) do
      use_sensu!
      use_docker!
      use_logstash_forwarder! do |config|
        # Collect logs for each docker container
        config["files"] << {
          "paths" => [ "/var/lib/docker/containers/*/*-json.log" ],
          "fields"=> { "type"=> "docker-container-json" }
        }

        # Collect logs for the docker daemon
        config["files"] << {
          "paths"=> [ "/var/log/upstart/docker.log" ],
          "fields"=> { "type"=> "docker-upstart" }
        }
      end
      execute_batch("Configure firewall" => {
        "ALLOW ssh port 22" => "ufw allow ssh",
        "ALLOW docker api port 4243" => "ufw allow 4243",
        "Enable firewall" => "yes | ufw enable",
        "Restart docker" => "service docker restart"
      })
    end
  end
end
