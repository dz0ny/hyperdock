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
    worker.perform(@container.id)
  end
end
