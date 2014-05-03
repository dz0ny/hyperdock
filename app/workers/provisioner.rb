class Provisioner
  include Sidekiq::Worker
  def perform(container_id)
    container = Container.find(container_id)
    docker_url = "http://cry.li:5422"
    response = `curl -X POST #{docker_url}/images/create --data "fromImage=#{container.image.docker_index}"`
    Rails.logger.info response

    cmd  = %{curl -H 'Content-Type: application/json' -X POST -d '#{container.config}' #{docker_url}/containers/create}
    response2 = `#{cmd}`
    Rails.logger.info response2
    res = JSON.parse(response2)
    if warning = res["Warnings"]
      Rails.logger.warn warning
    end
    container.update(instance_id: res["Id"])
    container.update(status: "created")
  end
end
