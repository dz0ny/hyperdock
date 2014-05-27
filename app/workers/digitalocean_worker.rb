##
# Keeps trying to get an IP address
class DigitaloceanWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  class NoIpAddressYetError < StandardError ; end

  def perform(host_id)
    record = Host.find(host_id)
    logger.info "Getting IP address for Digitalocean host #{record.name}"
    ch = WebsocketRails["host_#{record.id}".to_sym]
    info = Cloud.get_vm record.digitalocean_id
    if addr = info.ip_address
      record.ip_address = addr
      ch.trigger 'provisioner', { event: 'stdout', message: "Acquired IP address: #{addr}" }
      record.ip_address = info.ip_address
      record.save!
    else
      raise NoIpAddressYetError
    end
  end
end
