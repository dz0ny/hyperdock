class Provisioner
  include Sidekiq::Worker
  def perform(container_id)
    container = Container.find(container_id)
    container.host.docker.pull(container.image) do |chunk|
      logger.info chunk
      # http://mycatwantstolearnrails.blogspot.com/2013/04/rails-faye-sidekiq-redis.html
    end
    res = container.host.docker.create(container)
    logger.info res
    if warning = res["Warnings"]
      logger.warn warning
    end
    container.update(instance_id: res["Id"], status: "created")
  end
end
