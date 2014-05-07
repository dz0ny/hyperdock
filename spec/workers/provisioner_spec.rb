require 'spec_helper'

describe Provisioner do
  let(:worker) { Provisioner.new }
  let(:container) { create(:container) }

  before(:each) do
    stub_docker_pull container.host, container.image
    stub_docker_run container.host, container.image
  end

  it "provisions a container" do
    worker.perform(container.id)
  end
end
