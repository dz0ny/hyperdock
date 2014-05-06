module ContainersHelper
  def simplify_container_port_bindings json_string
    JSON.parse(json_string).map {|port, pair| pair[0]["HostPort"]+"/"+port.split('/')[1] }.join(', ') rescue "N/A"
  end
end
