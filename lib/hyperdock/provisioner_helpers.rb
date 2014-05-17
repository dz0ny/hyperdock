module Hyperdock
  module ProvisionerHelpers
    def ubuntu_lts?
      ssh.exec!('lsb_release -rs') =~ /1(2|4).04/
    end

    def ubuntu_1204?
      ssh.exec!('lsb_release -rs') =~ /12.04/
    end

    def ubuntu_1404?
      ssh.exec!('lsb_release -rs') =~ /14.04/
    end

    def package_installed? name
      output = ssh.exec!("apt-cache policy #{name}")
      !!(output =~ /Installed/) && !!!(output =~ /Installed: \(none\)/)
    end

    def command_missing? cmd
      !ssh.exec!(%{hash #{cmd} 2>&1 /dev/null || echo "MISSING"}).nil?
    end
  end
end
