class Host < ActiveRecord::Base
  def docker_url
    "http://#{self.ip_address}:#{self.port.to_s}"
  end
  def validate
    # Ensure that this docker host is available
    #binding.pry
  end
end
