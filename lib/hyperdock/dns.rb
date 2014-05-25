require 'cloudflare'

module Hyperdock
  module DNS
    def add_dns_record type, name, target
      begin
        cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
        subdomain = name.gsub(ENV['FQDN'], '')
        cf.rec_new(ENV['FQDN'], type.to_s.upcase, subdomain, target, 1)
      rescue => ex
        if ex.message =~ /already exists/
          log_after "DNS record #{name} => #{target} already exists"
        else
          raise ex
        end
      else
        log_after "Added DNS record #{name} => #{target}"
      end
    end
  end
end

