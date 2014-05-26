require 'hyperdock/nginx'

module Hyperdock
  module DockerSetup
    include Nginx
    DOCKER_CONF_DIR = Rails.root.join('config/docker')
    DOCKER_CERT_TAR = DOCKER_CONF_DIR.join('ssl_certs.tar')
    DOCKER_INSTALL_SCRIPT = "curl https://get.docker.io/ubuntu/ | sh 2>&1 > /dev/null"

    def use_docker!
      if package_installed? 'docker.io'
        configure_docker!
      else
        install_docker!
      end
    end

    def install_docker!
      log "Installing docker ..."
      stream_exec(DOCKER_INSTALL_SCRIPT) { configure_docker! }
    end

    def configure_docker!
      log "Configuring docker ..."
      dir = "/var/ssl/docker"
      ssh.exec!("rm -rf #{dir} 2>&1 > /dev/null &&  mkdir -p #{dir}")
      scp.upload! DOCKER_CERT_TAR.to_s, dir
      stream_exec(%{
        cd #{dir}
        tar -xvf ssl_certs.tar
        cd ssl_certs
        ./ssl_certs.sh generate 2>/dev/null
      }) do
        dir = "#{dir}/ssl_certs"
        tmp = Rails.root.join('tmp/docker')
        FileUtils.rm_rf(tmp) if tmp.exist?
        FileUtils.mkdir_p(tmp)
        cert = tmp.join('cert')
        key = tmp.join('key')
        ca = tmp.join('ca')
        scp.download!("#{dir}/client/cert.pem", cert)
        scp.download!("#{dir}/client/key.pem", key)
        scp.download!("#{dir}/docker_ca/cacert.pem", ca)
        update_local_env 'DOCKER_CLIENT_CERT' => cert.read
        update_local_env 'DOCKER_CLIENT_KEY' => key.read
        update_local_env 'DOCKER_CA_CERT' => ca.read
        remote_write('/etc/default/docker', %{DOCKER_OPTS="--tlsverify --tlscacert=#{dir}/docker_ca/cacert.pem --tlscert=#{dir}/server/cert.pem --tlskey=#{dir}/server/key.pem -H=0.0.0.0:4243"}.strip)
      end
    end
  end
end
