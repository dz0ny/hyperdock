require 'container_provisioner'
require 'monitor_provisioner'
require 'host_provisioner'

class Provisioner
  include Sidekiq::Worker

  def perform(class_string, id)
    opts = {logger: logger}
    case class_string
    when 'Host'
      provision_host Host.find(id), opts
    when 'Container'
      provision_container Container.find(id), opts
    end
  end

  def provision_host record, opts
    klass = record.monitor? ? MonitorProvisioner : HostProvisioner
    provisioner = klass.new(record.ip_address, 'root', opts[:password], record.name)
    provisioner.on_output do |data|
      ch = "host_#{record.id}".to_sym
      WebsocketRails[ch].trigger 'provisioner', data
    end
    provisioner.provision_test!
  end

  ##
  # You won't always pull an image when provisioning.
  # Sometimes you'll be using a local image. FIXME
  def provision_container record, opts
    opts[:container] = record
    provisioner = ContainerProvisioner.new opts
    provisioner.provision! do |data|
      ch = "container_#{opts[:container].id}".to_sym
      WebsocketRails[ch].trigger 'provisioner', data
    end
  end
end
