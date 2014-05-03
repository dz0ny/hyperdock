class Host < ActiveRecord::Base
  include ActiveModel::Validations
  validates_with DockerHostValidator

  def docker_url
    "http://#{self.ip_address}:#{self.port.to_s}"
  end

  validates :name, presence: true
  validates :ip_address, :format => { :with => Regexp.union(Resolv::IPv4::Regex, Resolv::IPv6::Regex) }
  validates :port, numericality: { only_integer: true, less_than_or_equal_to: 65535, greater_than: 0  }

  def get_info
    uri = URI(self.docker_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    res = http.get('/info')
    JSON.parse(res.body)
  end
end
