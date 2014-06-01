##
# Abstract the clouds
module Cloud
  class << self
    include Hyperdock::DNS

    ##
    # Create an ssh key
    def create_ssh_key name, pub_key
      Digitalocean::SshKey.create(name, pub_key).ssh_key
    end

    def destroy_ssh_key id
      Digitalocean::SshKey.destroy(id)
    end

    ##
    # Create an ubuntu 14.04 x64 virtual machine on digitalocean
    def create_vm name, size_id, region_id, ssh_key_id
      Digitalocean::Droplet.create({
        name: name,
        size_id: size_id,
        image_id: 3240036,
        region_id: region_id,
        ssh_key_ids: ssh_key_id
      }).droplet
    end

    def get_vm id
      Digitalocean::Droplet.find(id).droplet
    end

    def destroy_vm(id)
      Digitalocean::Droplet.destroy(id)
    end

    def regions
      Rails.cache.fetch("cloud_regions") { Digitalocean::Region.all.regions }
    end

    def vm_sizes
      Rails.cache.fetch("cloud_vm_sizes") { Digitalocean::Size.all.sizes }
    end

    def get_region(id)
      Rails.cache.fetch("cloud_region_#{id}") do
        Digitalocean::Region.find(id).region
      end
    end
  end
end
