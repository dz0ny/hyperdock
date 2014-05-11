require 'docker/client'

class Host < ActiveRecord::Base
  has_many :containers
  belongs_to :region

  after_save :update_region
  after_destroy :update_region

  validates :name, presence: true
  validates :ip_address, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex) }, uniqueness: { scope: :port, message: "and port belong to another host" }
  validates :port, numericality: { only_integer: true, less_than_or_equal_to: 65535, greater_than: 0  }

  def info
    OpenStruct.new(get_info)
  end

  def docker_url
    "http://#{self.ip_address}:#{self.port.to_s}"
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

  private

  def update_region
    self.region.update_available_hosts_counter
  end
end
