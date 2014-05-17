require 'ssh_wrapper'
require 'hyperdock/sensu'

class HostProvisioner < SshWrapper
  PORT = 5542
  DOCKER_HOST = "0.0.0.0:#{PORT}"
  DOCKER_OPTS = "-H #{DOCKER_HOST}"

  include Hyperdock::Sensu

  def provision!
    log "Connecting over SSH"
    connect do
      if ubuntu_lts?
        if kernel_upgraded?
          if command_missing?('docker')
            install_docker!
          else
            if docker_listening?
            else
              configure_docker!
            end
          end
        else
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

  private

  def wait_for_docker
    while ! docker_listening?
      log "Waiting for Docker..."
      sleep 1
    end
    log "Docker remote API is listening on #{@host}:#{PORT}"
    yield if block_given?
  end

  def ubuntu_lts?
    ssh.exec!('lsb_release -rs') =~ /1(2|4).04/
  end

  def kernel_upgraded?
    package_installed?("linux-image-generic-lts-raring") &&
      package_installed?("linux-headers-generic-lts-raring")
  end

  def upgrade_kernel!
    script = %{
        apt-get -y update
        apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring
        reboot
    }
    raise "not implemented"
    # stream_exec(script)
  end

  def package_installed? name
    ssh.exec!("apt-cache policy #{name}") =~ /Installed/
  end

  def command_missing? cmd
    !ssh.exec!(%{hash #{cmd} 2>&1 /dev/null || echo "MISSING"}).nil?
  end

  def docker_listening?
    ssh.exec!("docker #{DOCKER_OPTS} ps") =~ /CONTAINER/
  end

  def install_docker!
    cmd = "curl -s https://get.docker.io/ubuntu/ | sh"
    stream_exec(cmd) do
      configure_docker!
    end
  end

  def configure_docker!
    script = %{
        cat /etc/init/docker.conf | sed 's/DOCKER_OPTS=/DOCKER_OPTS="#{DOCKER_OPTS}"/' > /root/docker.conf
        cat /root/docker.conf > /etc/init/docker.conf
        rm /root/docker.conf

        mkdir -p /var/hyperdock/volumes

        ufw disable

        echo 'export DOCKER_HOST="#{DOCKER_HOST}"' > /root/.bashrc

        service docker restart && sleep 1
    }
    log "Reconfiguring Docker to start with options #{DOCKER_OPTS}"
    stream_exec(script)
  end
end
