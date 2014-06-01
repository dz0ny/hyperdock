##
# Keeps trying to get an IP address
class DigitaloceanWorker
  attr_reader :record
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(action, *args)
    self.send(action.strip.to_sym, *args)
  end

  def destroy vm_id, ssh_key_id, domains=[]
    Cloud.destroy_vm vm_id
    Cloud.destroy_ssh_key ssh_key_id
    domains.each {|dn|
      logger.info "Removing domain #{dn}"
      logger.info Cloud.remove_dns_record(dn).inspect
    }
  end

  def create host_id
    prepare_record host_id
    trigger 'stdout', message: "Generating ssh identity ..."
    record.generate_ssh_identity
    record.reload
    ssh_key = Cloud.create_ssh_key record.name, record.ssh_public_key
    record.digitalocean_ssh_key_id = ssh_key.id
    trigger 'stdout', message: "Creating cloud virtual machine"
    vm = Cloud.create_vm record.name, record.digitalocean_size_id, record.digitalocean_region_id, ssh_key.id
    record.digitalocean_id = vm.id
    record.save!
    trigger 'stdout', message: "Acquiring IP address ..."
    self.class.perform_in(10.seconds, :get_ip_address, record.id)
  end

  def get_ip_address host_id
    prepare_record host_id
    info = Cloud.get_vm record.digitalocean_id
    until addr = info.ip_address
      trigger 'stdout', message: "Still waiting for an IP address ..."
      sleep 10.seconds
    end
    record.ip_address = addr
    trigger 'stdout', message: "Acquired IP address: #{addr}"
    record.ip_address = info.ip_address
    record.save!
  end

  private
    def prepare_record host_id
      @record = Host.find(host_id)
      @ch = WebsocketRails["host_#{record.id}".to_sym]
    end

    def trigger name, details={}
      @ch.trigger 'provisioner', { event: name }.merge(details)
    end
end
