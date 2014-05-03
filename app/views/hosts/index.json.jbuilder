json.array!(@hosts) do |host|
  json.extract! host, :id, :name, :ip_address, :port
  json.url host_url(host, format: :json)
end
