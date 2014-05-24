require 'container_provisioner'
require 'monitor_provisioner'
require 'host_provisioner'

class Provisioner
  include Sidekiq::Worker
  sidekiq_options unique: true,
    unique_args: :unique_args

  def self.unique_args(model, id, options)
    [ model, id ]
  end

  def perform(class_string, id, opts={})
    case class_string
    when 'Host'
      provision_host Host.find(id), opts["password"]
    when 'Container'
      provision_container Container.find(id)
    end
  end

  def provision_host record, password=nil
    logger.info "Provisioning host #{record.name} #{record.ip_address}"
    ch = WebsocketRails["host_#{record.id}".to_sym]
    klass = record.monitor? ? MonitorProvisioner : HostProvisioner
    provisioner = klass.new(record.ip_address, 'root', password, record.name)
    provisioner.on_output {|data|
      if msg = data[:log]
        ch.trigger 'provisioner', { event: 'stdout', message: msg }
      elsif msg = data[:err]
        ch.trigger 'provisioner', { event: 'stderr', message: msg }
      else
        ch.trigger 'provisioner', { event: 'unknown', data: data }
      end
    }.on_exit {|code|
      ch.trigger 'provisioner', { event: 'exit', status: code }
    }
    begin
      provisioner.auth = record.ssh_identity
      ch.trigger 'provisioner', { event: 'start' }
      provisioner.provision!
    rescue => ex
      ch.trigger 'provisioner', { event: 'exception',
                                  class: ex.class.to_s, 
                                  message: ex.message, 
                                  backtrace: ex.backtrace }
    ensure
      record.ssh_identity = provisioner.auth
    end
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
