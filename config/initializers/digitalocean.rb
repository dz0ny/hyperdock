Digitalocean.client_id = ENV['DIGITALOCEAN_CLIENT_ID']
Digitalocean.api_key = ENV['DIGITALOCEAN_API_KEY']

Digitalocean::SshKey.singleton_class.send(:define_method, :destroy, -> (id) {
  url = "https://api.digitalocean.com/v1/ssh_keys/#{id}/destroy/?client_id=#{Digitalocean.client_id}&api_key=#{Digitalocean.api_key}"
  res = Net::HTTP.get(URI(url))
  RecursiveOpenStruct.new(JSON.parse(res))
})

Digitalocean::SshKey.singleton_class.send(:define_method, :create, -> (name, pub_key) {
  url = "https://api.digitalocean.com/v1/ssh_keys/new/?name=#{name}&ssh_pub_key=#{CGI.escape(pub_key)}&client_id=#{Digitalocean.client_id}&api_key=#{Digitalocean.api_key}"
  res = Net::HTTP.get(URI(url))
  RecursiveOpenStruct.new(JSON.parse(res))
})
