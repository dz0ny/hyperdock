class ContainerWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(action, *args)
    self.send(action.strip.to_sym, *args)
  end

  def remove host_id, instance_id
    logger.info "Removing docker container #{instance_id}"
    host = Host.find(host_id)
    if host && host.online?
      host.docker.stop instance_id
      host.docker.rm instance_id
    end
  rescue Docker::Client::InvalidInstanceIdError
    # The container was never created
  end
end
