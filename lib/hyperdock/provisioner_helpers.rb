module Hyperdock
  module ProvisionerHelpers
    def provisioner
      connect do
        if ubuntu_lts?
          yield
        else
          err "This is not an Ubuntu LTS server! Cannot continue."
          exit(2)
        end
      end
    end

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

    def file_exists? remote_path
      !!!ssh.exec!("stat #{remote_path}").match(/No such file or directory/)
    end

    def needs_package pkg
      unless package_installed? pkg
        log "Installing package: #{pkg}"
        ssh.exec!("DEBIAN_FRONTEND=noninteractive apt-get install -y #{pkg}")
      end
    end
  end
end
