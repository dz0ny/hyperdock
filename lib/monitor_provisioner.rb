require 'ssh_wrapper'
require 'hyperdock/sensu_monitor_setup'

class MonitorProvisioner < SshWrapper
  include Hyperdock::SensuMonitorSetup

  def provision!
    start do
      #needs_package 'wget'
      #unless package_installed? "influxdb
    end
  end
end
