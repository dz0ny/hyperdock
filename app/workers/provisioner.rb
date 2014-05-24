require 'container_provisioner'
require 'monitor_provisioner'
require 'host_provisioner'

class Provisioner
  include Sidekiq::Worker

  def perform(class_string, id)
    opts = {logger: logger}
    case class_string
    when 'Host'
      opts[:host] = Host.find(id)
      provision_host opts
    when 'Container'
      opts[:container] = Container.find(id)
      provision_container opts
    end
  end

  def provision_host host, opts
    if opts[:host].monitor?
      MonitorProvisioner.new opts
    else
      HostProvisioner.new opts
    end.event_log do |data|
      ch = "host_#{opts[:host].id}".to_sym
      WebsocketRails[ch].trigger 'provisioner', data
    end.provision!
  end

  ##
  # You won't always pull an image when provisioning.
  # Sometimes you'll be using a local image. FIXME
  def provision_container opts
    provisioner = ContainerProvisioner.new opts
    provisioner.provision! do |data|
      ch = "container_#{opts[:container].id}".to_sym
      WebsocketRails[ch].trigger 'provisioner', data
    end
  end
end
