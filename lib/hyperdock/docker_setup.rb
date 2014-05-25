module Hyperdock
  module DockerSetup
    PORT = 5542
    DOCKER_HOST = "0.0.0.0:#{PORT}"
    DOCKER_OPTS = "-H #{DOCKER_HOST}"

    def wait_for_docker
      while ! docker_listening?
        log "Waiting for Docker..."
        sleep 1
      end
      log "Docker remote API is listening on #{@host}:#{PORT}"
      yield if block_given?
    end

    def kernel_upgraded?
      package_installed?("linux-image-generic-lts-raring") &&
        package_installed?("linux-headers-generic-lts-raring")
    end

    def upgrade_kernel!
      script = %{
          apt-get -y update > /dev/null
          apt-get -y install linux-image-generic-lts-raring linux-headers-generic-lts-raring
          reboot
      }
      raise "not implemented"
      # stream_exec(script)
    end

    def docker_listening?
      ssh.exec!("docker #{DOCKER_OPTS} ps") =~ /CONTAINER/
    end

    def install_docker!
      cmd = %{
        export DEBIAN_FRONTEND=noninteractive
        curl -s https://get.docker.io/ubuntu/ | sh
      }
      stream_exec(cmd) do
        configure_docker!
      end
    end

    def configure_docker!
      ssh.exec!('service docker stop')
      remote_write '/etc/default/docker', %{DOCKER_OPTS="#{DOCKER_OPTS}"}
      ssh.exec!('ufw disable')
      script = %{
      echo 'export DOCKER_HOST="#{DOCKER_HOST}"' > /root/.bashrc
      service docker start
      }
      log "Reconfiguring Docker to start with options #{DOCKER_OPTS}"
      stream_exec(script)
    end
  end
end
