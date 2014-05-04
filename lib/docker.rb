##
# Represents docker for a host
# Communicates over the network
# Add security patterns, etc here
class Docker
  attr_reader :base_uri

  def initialize base_uri
    @base_uri = base_uri
  end

  def info
    uri = URI.join(base_uri, "/info")
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    res = http.get(uri.request_uri)
    JSON.parse(res.body)
  end

  def pull image
    uri = URI.join(base_uri, "/images/create")
    http = Net::HTTP.new(uri.host, uri.port)
    http.request_post(uri.request_uri, "fromImage=#{image.docker_index}") do |response|
      response.read_body do |chunk|
        yield chunk
      end
    end
  end

  def run image
    uri = URI.join(base_uri, "/containers/create")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(req).body
  end
end
