##
# Represents docker for a host
# Communicates over the network
# Add security patterns, etc here
class Docker
  class InvalidInstanceIdError < StandardError ; end
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

  def inspect id
    raise InvalidInstanceIdError if id.nil?
    uri = URI.join(base_uri, "/containers/#{id}/json")
    req = Net::HTTP::Get.new(uri)
    req["Content-Type"] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    res = http.request(req)
    JSON.parse(res.body)
  end

  def top id
    raise InvalidInstanceIdError if id.nil?
    uri = URI.join(base_uri, "/containers/#{id}/top")
    req = Net::HTTP::Get.new(uri)
    req["Content-Type"] = "application/json"
    http = Net::HTTP.new(uri.host, uri.port)
    http.open_timeout = 2
    http.read_timeout = 2
    res = http.request(req)
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

  def run image, config
    uri = URI.join(base_uri, "/containers/create")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = config
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
    JSON.parse response.body
  end

  def start id, config
    raise InvalidInstanceIdError if id.nil?
    uri = URI.join(base_uri, "/containers/#{id}/start")
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req.body = config
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
    response.body
  end

  def stop id
    raise InvalidInstanceIdError if id.nil?
    uri = URI.join(base_uri, "/containers/#{id}/stop?t=0")
    req = Net::HTTP::Post.new(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
    response.body
  end

  def restart id
    raise InvalidInstanceIdError if id.nil?
    uri = URI.join(base_uri, "/containers/#{id}/restart?t=0")
    req = Net::HTTP::Post.new(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
    response.body
  end


  def rm id
    raise InvalidInstanceIdError if id.nil?
    uri = URI.join(base_uri, "/containers/#{id}?v=1&force=1")
    req = Net::HTTP::Delete.new(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.request(req)
    response.body
  end
end
