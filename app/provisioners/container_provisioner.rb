##
# ContainerProvisioner.new({container: container}).provision!
class ContainerProvisioner < OpenStruct
  def provision!
    logger.info "Provisioning container ID #{container.id}"
    container.host.docker.pull(container.image) do |chunk|
      yield(chunk: chunk) if block_given?
    end
    res = container.host.docker.create(container, container.config[:for_create])
    if warnings = res["Warnings"]
      logger.warn "Warnings while provisioning container ID #{container.id}:\n#{warnings}\n"
    end
    logger.info "Finished provisioning container ID #{container.id}:\n#{res}\n"
    yield(done: true, info: res, warnings: warnings) if block_given?
    container.update(instance_id: res["Id"], status: "created")
  end
end
