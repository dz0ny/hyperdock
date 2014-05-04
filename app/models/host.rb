require('docker')

class Host < ActiveRecord::Base
  include ActiveModel::Validations
  validates_with DockerHostValidator
  has_many :containers

  def docker_url
    "http://#{self.ip_address}:#{self.port.to_s}"
  end

  validates :name, presence: true
  validates :ip_address, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex) }, uniqueness: { scope: :port, message: "and port belong to another host" }
  validates :port, numericality: { only_integer: true, less_than_or_equal_to: 65535, greater_than: 0  }

  def get_info
    uri = URI.join(self.docker_url, "/info")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    res = http.get(uri.request_uri)
    JSON.parse(res.body)
  end

  def info
    JSON.pretty_generate(get_info) rescue "None"
  end

  def docker
    @docker ||= Docker.new(self)
  end
end
