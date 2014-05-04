require 'spec_helper'

describe Provisioner do
  let(:worker) { Provisioner.new }
  let(:host) { build(:host) }
  let(:container) { create(:container, host: host) }

  before(:each) do
    stub_get_info host
    stub_docker_pull container.host, container.image
    stub_docker_run container.host, container.image
  end

  it "provisions a container" do
    worker.perform(container.id)
  end
end
