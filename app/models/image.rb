class Image < ActiveRecord::Base
  # "4873/tcp": [{ "HostPort": "0" }]
 
  before_save :format_port_bindings

  def format_port_bindings
    self.port_bindings = self.port_bindings.split(',').map do |port|
      %{"#{port.strip}/tcp": [{ "HostIp": "0.0.0.0", "HostPort": "0" }]}
    end.join(',')
  end
end
