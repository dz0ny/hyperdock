require 'ssh_wrapper'
require 'hyperdock/provisioner_helpers'

class MonitorProvisioner < SshWrapper
  include Hyperdock::ProvisionerHelpers

  def provision!
    provisioner do
      #needs_package 'wget'
      #unless package_installed? "influxdb
    end
  end
end
