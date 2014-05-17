require 'ssh_wrapper'
require 'hyperdock/sensu_setup'
require 'hyperdock/docker_setup'
require 'hyperdock/provisioner_helpers'

class HostProvisioner < SshWrapper
  include Hyperdock::SensuSetup
  include Hyperdock::DockerSetup
  include Hyperdock::ProvisionerHelpers

  def provision!
    log "Connecting over SSH"
    connect do
      if ubuntu_lts?
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
        wait_for_docker { use_sensu! }
      else
        err "This is not an Ubuntu LTS server! Cannot continue."
        exit(2)
      end
    end
  end
end
