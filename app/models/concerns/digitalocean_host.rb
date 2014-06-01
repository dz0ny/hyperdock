module DigitaloceanHost
  extend ActiveSupport::Concern

  included do
    validates :digitalocean_size_id, presence: true
    validates :digitalocean_region_id, presence: true
    before_create :assign_region
    after_create :setup_cloud_vm
    after_destroy :delete_cloud_vm
  end

  def assign_region
    self.region = Region.where(:digitalocean_id => self.digitalocean_region_id).first_or_create
    self.name = "#{self.region.digitalocean_slug}-#{SecureRandom.hex(3)}"
  end

  def setup_cloud_vm
    DigitaloceanWorker.perform_in(2.seconds, :create, self.id)
  end

  def delete_cloud_vm
    DigitaloceanWorker.perform_async :destroy, self.digitalocean_id, self.digitalocean_ssh_key_id, self.domains
  end
end
