class Provisioner
  include Sidekiq::Worker
  def perform(container_id)
    container = Container.find(container_id)
    container.host.docker.pull(container.image) do |chunk|
      Rails.logger.info chunk
    end
    res = container.host.docker.run(container.image)
    Rails.logger.info res
    if warning = res["Warnings"]
      Rails.logger.warn warning
    end
    container.update(instance_id: res["Id"])
    container.update(status: "created")
  end
end
