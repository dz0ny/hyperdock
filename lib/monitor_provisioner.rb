require 'ssh_wrapper'
require 'hyperdock/sensu_monitor_setup'

class MonitorProvisioner < SshWrapper
  include Hyperdock::SensuMonitorSetup

  def provision!
    start( version: '14.04' ) do
      use_sensu!
    end
  end

end
