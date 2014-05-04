require 'spec_helper'

describe Container do
  let(:host) { build(:host) }
  let(:container) { create(:container, host: host) }

  before(:each) do
    stub_get_info host
  end

  it "#get_info uses docker api to inspect the container" do
    container.host.docker.should_receive(:inspect).with(container.instance_id)
    container.get_info
  end

  describe "#destroy" do
    it "removes it from the host before removing it from the database" do
      container.host.docker.should_receive(:rm).with(container.instance_id)
      container.destroy
      container.should_not be_persisted
    end
  end

  describe "#stop" do
    it "stops the docker container instance" do
      container.host.docker.should_receive(:stop).with(container.instance_id)
      container.stop
      container.status.should eq "stopped"
    end
  end
end
