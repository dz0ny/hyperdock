require 'spec_helper'

describe Provisioner do
  let(:worker) { Provisioner.new }

  before(:each) do
    host = build :host
    @get_info_stub = stub_get_info host
    @container = create(:container, host: host)
  end

  after(:each) do
    remove_request_stub(@get_info_stub)
  end

  it "provisions a container" do
    stub_docker_pull @container.host, @container.image
    stub_docker_run @container.host, @container.image
    worker.perform(@container.id)
  end
end
