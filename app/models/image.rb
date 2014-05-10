class Image < ActiveRecord::Base
  before_create :format_port_bindings
  serialize :env_defaults, Array

  def format_port_bindings
    self.port_bindings = self.port_bindings.split(',').map do |port|
      proto = (port =~ /udp/ ? "udp" : "tcp")
      %{"#{port.strip.to_i}/#{proto}": [{ "HostIp": "0.0.0.0", "HostPort": "0" }]}
    end.join(',')
  end
end
