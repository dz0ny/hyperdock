module DigitaloceanHost
  extend ActiveSupport::Concern

  included do
    before_create :assign_region
    after_create :setup_cloud_vm
    after_destroy :delete_cloud_vm
  end

  def assign_region
    self.region = Region.where(:digitalocean_id => self.digitalocean_region_id).first_or_create
    self.name = "#{self.region.digitalocean_slug}-#{SecureRandom.hex(3)}"
  end

  def setup_cloud_vm
    self.generate_ssh_identity
    ssh_key = Cloud.create_ssh_key self.name, self.ssh_public_key
    self.digitalocean_ssh_key_id = ssh_key.id
    vm = Cloud.create_vm self.name, self.digitalocean_size_id, self.digitalocean_region_id, ssh_key.id
    self.digitalocean_id = vm.id
    self.save!
    DigitaloceanWorker.perform_async(self.id)
  end

  def delete_cloud_vm
    Cloud.destroy_vm self.digitalocean_id
    Cloud.destroy_ssh_key self.digitalocean_ssh_key_id
  end
end
