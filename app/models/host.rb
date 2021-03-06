require 'docker/client'

class Host < ActiveRecord::Base
  include DigitaloceanHost
  include SecureShellIdentity
  include DockerHost
  include Monitoring
  include TempFolder

  has_many :containers, dependent: :destroy
  belongs_to :region

  after_save :update_region_status
  after_destroy :update_region_status

  def info
    OpenStruct.new(get_info)
  end

  def remote_containers
    docker.containers(all: true, size: true).map do |c|
      rc = OpenStruct.new(c)
      rc.image = Image.where(docker_index: rc.Image.split(':').first) rescue nil
      rc.proxy = self.containers.where(instance_id: rc.Id).first if rc.Id
      rc
    end
  end

  def online?
    info = self.get_info
    if self.persisted?
      if info && info.has_key?("Containers")
        self.update(healthy: true)
      else
        self.update(healthy: false)
      end
    end
    self.healthy
  end

  def provisioned?
    not ssh_private_key.empty?
  end

  def ssh
    auth = ssh_identity
    Net::SSH.start(self.ip_address, 'root', { keys: auth[:private_key].to_s, keys_only: true, user_known_hosts_file: auth[:known_hosts].to_s }) do |ssh|
      yield(ssh, ssh.scp)
    end
  end

  def domains
    arr = []
    if self.is_monitor
      arr << "kibana.#{self.name}.#{ENV['FQDN']}"
      arr << "sensu.#{self.name}.#{ENV['FQDN']}"
    end
    arr
  end

  private

  def update_region_status
    self.region.update_available_hosts_counter
  end
end
