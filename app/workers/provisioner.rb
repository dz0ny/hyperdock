require 'container_provisioner'
require 'monitor_provisioner'
require 'host_provisioner'

class Provisioner
  include Sidekiq::Worker
  sidekiq_options retry: false, unique: true, unique_args: :unique_args

  def self.unique_args(model, id, options={})
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

  def trigger name, details={}
    @ch.trigger 'provisioner', { event: name }.merge(details)
  end

  def provision_host record, password=nil
    ENV["RABBITMQ_HOST"] = record.monitor.rabbitmq_host
    ENV["LOGSTASH_SERVER"] = record.monitor.logstash_server
    logger.info "Provisioning host #{record.name} #{record.ip_address}"
    @ch = WebsocketRails["host_#{record.id}".to_sym]
    status = 127
    start_time = Time.now
    begin
      klass = record.monitor? ? MonitorProvisioner : HostProvisioner
      provisioner = klass.new(record.ip_address, 'root', password, record.name)
      provisioner.on_output {|out, err|
        trigger 'stdout', message: out if out
        trigger 'stderr', message: err if err
      }.on_exit {|code|
        status = code
      }.before_connect {
        provisioner.auth = record.ssh_identity
      }.after_configured_passwordless_login {
        record.ssh_identity = provisioner.auth
      }.on_update_env {|key, value|
        record.update_attribute(key, value)
      }.set_monitor { record.monitor }
      trigger 'start'
      provisioner.provision!
      status = 0
    rescue => ex
      trigger 'stderr', message: "#{ex.class.to_s} #{ex.message}"
      ex.backtrace.each {|bt| trigger 'stderr', message: "#{bt}" }
    ensure
      trigger 'exit', status: status
      logger.info "No longer provisioning host #{record.name} #{record.ip_address} after #{Time.now - start_time} seconds"
    end
  end

  ##
  # You won't always pull an image when provisioning.
  # Sometimes you'll be using a local image. FIXME
  def provision_container record
    provisioner = ContainerProvisioner.new container: record, logger: logger
    logger.info "Provisioning container #{record.id} #{record.name}"
    @ch = WebsocketRails["container_#{record.id}".to_sym]
    provisioner.provision! do |data|
      if out = data[:chunk]
        trigger 'stdout', message: out
      elsif data[:done]
        trigger 'stdout', message: "Done", info: data[:info], warnings: data[:warnings]
        logger.info "No longer provisioning container #{record.id} #{record.name}"
      end
    end
  end
end
