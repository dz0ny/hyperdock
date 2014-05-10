require('docker')

class Host < ActiveRecord::Base
  has_many :containers
  belongs_to :region

  after_save :update_region
  after_destroy :update_region

  validates :name, presence: true
  validates :ip_address, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex) }, uniqueness: { scope: :port, message: "and port belong to another host" }
  validates :port, numericality: { only_integer: true, less_than_or_equal_to: 65535, greater_than: 0  }

  def info
    JSON.pretty_generate(docker.info) rescue "None"
  end

  def docker_url
    "http://#{self.ip_address}:#{self.port.to_s}"
  end

  def get_info
    docker.info
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
    @docker ||= Docker.new(docker_url)
  end

  private

  def update_region
    self.region.update_available_hosts_counter
  end
end
