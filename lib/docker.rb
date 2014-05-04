##
# Represents docker for a host
# Communicates over the network
# Add security patterns, etc here
class Docker
  def initialize host
    @host = host  
  end

  def pull image
    uri = URI.join(@host.docker_url, "/images/create")
    http = Net::HTTP.new(uri.host, uri.port)
    http.request_post(uri.request_uri, "fromImage=#{image.docker_index}") do |response|
      response.read_body do |chunk|
        yield chunk
      end
    end
  end

  def run image
    uri = URI.join(@host.docker_url, "/containers/create")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.request(req).body
  end
end
