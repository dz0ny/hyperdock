module Hyperdock
  module ProvisionerHelpers
    def ubuntu_lts?
      ssh.exec!('lsb_release -rs') =~ /1(2|4).04/
    end

    def package_installed? name
      ssh.exec!("apt-cache policy #{name}") =~ /Installed/
    end

    def command_missing? cmd
      !ssh.exec!(%{hash #{cmd} 2>&1 /dev/null || echo "MISSING"}).nil?
    end
  end
end
