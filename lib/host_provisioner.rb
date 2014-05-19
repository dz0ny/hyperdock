require 'ssh_wrapper'
require 'hyperdock/sensu_setup'
require 'hyperdock/docker_setup'
require 'hyperdock/logstash_forwarder_setup'

class HostProvisioner < SshWrapper
  include Hyperdock::SensuSetup
  include Hyperdock::DockerSetup
  include Hyperdock::LogstashForwarderSetup

  def provision!
    start do
      if ubuntu_1404? || kernel_upgraded?
        if command_missing?('docker')
          install_docker!
        elsif ! docker_listening?
          configure_docker!
        end
      elsif ubuntu_1204?
        upgrade_kernel!
        install_docker!
      end
      wait_for_docker do
        use_sensu!
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
      end
    end
  end
end
