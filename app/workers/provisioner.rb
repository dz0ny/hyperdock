require 'container_provisioner'
require 'monitor_provisioner'
require 'host_provisioner'

class Provisioner
  include Sidekiq::Worker

  def perform(class_string, id, opts={})
    case class_string
    when 'Host'
      mutex = Redis::Mutex.new opts["mutex_key"]
      binding.pry
      provision_host Host.find(id), mutex, opts["password"]
    when 'Container'
      provision_container Container.find(id)
    end
  end

  def provision_host record, mutex, password=nil
    logger.info "Provisioning host #{record.name} #{record.ip_address}"
    ch = WebsocketRails["host_#{record.id}".to_sym]
    klass = record.monitor? ? MonitorProvisioner : HostProvisioner
    provisioner = klass.new(record.ip_address, 'root', password, record.name)
    provisioner.on_exit {|code|
      mutex.unlock
      ch.trigger 'provisioner', {success: code == 0}
    }.on_output {|data|
      ch.trigger 'provisioner', data
    }
    sleep 1
    provisioner.log 'fake output'
    sleep 1
    provisioner.exit(2)

      #.provision!
  end

  ##
  # You won't always pull an image when provisioning.
  # Sometimes you'll be using a local image. FIXME
  def provision_container record
    provisioner = ContainerProvisioner.new container: record, logger: logger
    provisioner.provision! do |data|
      ch = "container_#{record.id}".to_sym
      logger.info data
      WebsocketRails[ch].trigger 'provisioner', data
    end
  end
end
