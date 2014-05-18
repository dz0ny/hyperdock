require 'ssh_wrapper'

class MonitorProvisioner < SshWrapper

  def provision!
    start do
      #needs_package 'wget'
      #unless package_installed? "influxdb
    end
  end
end
