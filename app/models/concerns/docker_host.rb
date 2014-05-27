module DockerHost
  extend ActiveSupport::Concern

  def get_info
    @info ||= docker.info
  end

  def docker
    @client ||= Docker::Client.new(self)
  end

  def docker_ca_file
    file = self.tmp.join('ca_file')
    file.write(self.docker_ca_cert) unless file.exist?
    file
  end

  def docker_url
    "https://#{self.ip_address}:4243"
  end
end

