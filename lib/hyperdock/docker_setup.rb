require 'hyperdock/nginx'

module Hyperdock
  module DockerSetup
    include Nginx
    DOCKER_INSTALL_SCRIPT = <<-EOF
      export DEBIAN_FRONTEND=noninteractive
      apt-get update > /dev/null
      apt-get install -y docker.io
      ln -sf /usr/bin/docker.io /usr/local/bin/docker
    EOF

    def use_docker!
      if package_installed? 'docker.io'
        configure_docker!
      else
        install_docker!
      end
    end

    def install_docker!
      stream_exec(DOCKER_INSTALL_SCRIPT) { configure_docker! }
    end
  end
end
