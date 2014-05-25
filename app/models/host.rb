require 'docker/client'

class Host < ActiveRecord::Base
  has_many :containers, dependent: :destroy
  belongs_to :region

  after_save :update_region
  after_destroy :update_region

  validates :name, presence: true
  validates :ip_address, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex) }, uniqueness: true

  def info
    OpenStruct.new(get_info)
  end

  def docker_url
    "https://#{self.ip_address}:443"
  end

  def get_info
    @info ||= docker.info
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

  def docker
    @client ||= Docker::Client.new(docker_url)
  end

  def remote_containers
    docker.containers(all: true, size: true).map do |c|
      rc = OpenStruct.new(c)
      rc.image = Image.where(docker_index: rc.Image.split(':').first) rescue nil
      rc.proxy = self.containers.where(instance_id: rc.Id).first if rc.Id
      rc
    end
  end

  def monitor?
    self.is_monitor
  end

  def is_monitor!
    self.update_column(:is_monitor, true)
  end

  def tmp
    path = Rails.root.join("tmp/hosts/#{self.id}")
    FileUtils.mkdir_p(path) unless path.exist?
    path
  end

  def ssh_auth_files
    ident = { private_key: tmp.join("id_rsa"),
              public_key: tmp.join("id_rsa.pub"),
              known_hosts: tmp.join("known_hosts") }
  end

  def ssh_identity
    ident = ssh_auth_files
    ident[:private_key].write self.ssh_private_key
    ident[:public_key].write self.ssh_public_key
    ident[:known_hosts].write self.ssh_known_hosts
    ident
  end

  def ssh_identity= ident
    self.ssh_private_key = ident[:private_key].read 
    self.ssh_public_key = ident[:public_key].read
    self.ssh_known_hosts = ident[:known_hosts].read
    self.save!
  end

  ##
  # Find the region monitor
  def monitor
    monitor? ? self : region.hosts.where(is_monitor: true).first
  end

  private

  def update_region
    self.region.update_available_hosts_counter
  end
end
