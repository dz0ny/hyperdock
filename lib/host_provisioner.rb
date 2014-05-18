require 'ssh_wrapper'
require 'hyperdock/sensu_setup'
require 'hyperdock/docker_setup'
require 'hyperdock/logstash_forwarder_setup'
require 'hyperdock/provisioner_helpers'

class HostProvisioner < SshWrapper
  include Hyperdock::SensuSetup
  include Hyperdock::DockerSetup
  include Hyperdock::LogstashForwarderSetup
  include Hyperdock::ProvisionerHelpers

  def provision!
    provisioner do
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
        use_logstash_forwarder!
      end
    end
  end
end
