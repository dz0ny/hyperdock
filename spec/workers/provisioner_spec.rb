require 'spec_helper'

describe Provisioner do
  let(:worker) { Provisioner.new }
  let(:region) { container.host.region }
  let(:host) { container.host }
  let(:container) { create(:container) }

  before(:each) do
    stub_get_info host
    stub_docker_pull container.host, container.image
    stub_docker_run container.host, container.image
  end

  it "provisions a container" do
    worker.perform(container.id)
  end
end
