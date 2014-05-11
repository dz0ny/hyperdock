module ContainersHelper
  def simplify_container_port_bindings json_string
    JSON.parse(json_string).map {|port, pair| pair[0]["HostPort"]+"/"+port.split('/')[1] }.join(', ') rescue "N/A"
  end

  def extract_host_port port_pair_value
    port_pair_value[0]['HostPort'] rescue false
  end
end
