require 'cloudflare'

module Hyperdock
  module DNS
    ##
    # Pass in full domain name or subdomain, type, and IP target to add a record
    def add_dns_record type, name, target
      begin
        subdomain = name.gsub(ENV['FQDN'], '')
        cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
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

    ##
    # Pass in full domain name or subdomain to remove it
    def remove_dns_record name
      subdomain = name.gsub(".#{ENV['FQDN']}", '')
      name = "#{subdomain}.#{ENV['FQDN']}"
      cf = CloudFlare::connection(ENV['CLOUDFLARE_API_KEY'], ENV['CLOUDFLARE_EMAIL'])
      recs = cf.rec_load_all(ENV['FQDN'])["response"]["recs"]
      if recs["has_more"]
        raise "You have over 180 records and we haven't implemented offset yet! See https://www.cloudflare.com/docs/client-api.html"
      end
      record = recs["objs"].select{|h| h["name"] == name }[0]
      cf.rec_delete(ENV['FQDN'], record["rec_id"]) if record
    end
  end
end

