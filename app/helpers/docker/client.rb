require 'docker/default_configs'
require 'openssl'

##
# Represents docker for a host
# Communicates over the network
module Docker
  class Client
    class InvalidInstanceIdError < StandardError ; end
    class NoSuchContainerError < StandardError ; end
    class ServerError < StandardError ; end

    include DefaultConfigs

    attr_reader :base_uri

    def initialize record
      @base_uri = record.docker_url
      @cert = record.docker_client_cert
      @key = record.docker_client_key
      @ca_file = record.ca_file
      @verify_ca = false
    end

    def info
      uri = URI.join(base_uri, "/info")
      http = mkhttp uri
      http.open_timeout = 2
      http.read_timeout = 2
      res = http.get(uri.request_uri)
      JSON.parse(res.body)
    rescue => ex
      return nil
    end

    def inspect id
      raise InvalidInstanceIdError if id.nil?
      uri = URI.join(base_uri, "/containers/#{id}/json")
      req = Net::HTTP::Get.new(uri)
      req["Content-Type"] = "application/json"
      http = mkhttp uri
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
      http = mkhttp uri
      http.open_timeout = 2
      http.read_timeout = 2
      res = http.request(req)
      JSON.parse(res.body)
    end

    def pull image
      uri = URI.join(base_uri, "/images/create")
      http = mkhttp uri
      http.request_post(uri.request_uri, "fromImage=#{image.docker_index}") do |response|
        response.read_body do |chunk|
          yield chunk
        end
      end
    end

    def create container, config
      uri = URI.join(base_uri, "/containers/create")
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body = default_creation_config.merge(config).to_json
      http = mkhttp uri
      response = http.request(req)
      JSON.parse response.body
    end

    def start id, config
      raise InvalidInstanceIdError if id.nil?
      uri = URI.join(base_uri, "/containers/#{id}/start")
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req.body = default_start_config.merge(config).to_json
      http = mkhttp uri
      response = http.request(req)
      response.body
    end

    def stop id
      raise InvalidInstanceIdError if id.nil?
      uri = URI.join(base_uri, "/containers/#{id}/stop?t=0")
      req = Net::HTTP::Post.new(uri)
      http = mkhttp uri
      response = http.request(req)
      response.body
    end

    def restart id
      raise InvalidInstanceIdError if id.nil?
      uri = URI.join(base_uri, "/containers/#{id}/restart?t=0")
      req = Net::HTTP::Post.new(uri)
      http = mkhttp uri
      response = http.request(req)
      response.body
    end

    def rm id
      raise InvalidInstanceIdError if id.nil?
      uri = URI.join(base_uri, "/containers/#{id}?v=1&force=1")
      req = Net::HTTP::Delete.new(uri)
      http = mkhttp uri
      response = http.request(req)
      response.body
    end

    ##
    # http://docs.docker.io/reference/api/docker_remote_api_v1.11/#21-containers
    def containers options
      uri = URI.join(base_uri, "/containers/json?#{options.to_query}")
      http = mkhttp uri
      http.open_timeout = 2
      http.read_timeout = 4
      res = http.get(uri.request_uri)
      JSON.parse(res.body)
    end

    private
      def mkhttp uri
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.cert = OpenSSL::X509::Certificate.new(@cert)
        http.key = OpenSSL::PKey::RSA.new(@key)
        if @verify_ca
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        else
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        http.ca_file = @ca_file.to_s
        http
      end
  end
end
