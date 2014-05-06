require 'spec_helper'

describe Container do
  it { should validate_presence_of :name }

  let(:container) { build(:container) }

  describe "factory" do
    subject { container }
    it { should be_valid }   
    specify { subject.host.should be_a Host }
    specify { subject.region.should be_a Region }
    it "it gets assigned the host when saved" do
      subject.region.hosts.last.should_not eq subject.host
      subject.save
      subject.region.hosts.last.should eq subject.host
    end
  end

  it "#get_info uses docker api to inspect the container" do
    container.host.docker.should_receive(:inspect).with(container.instance_id)
    container.get_info
  end

  describe "#destroy" do
    before(:each) { container.save }
    it "stops and removes it from the host before removing it from the database" do
      container.should be_persisted
      container.should_receive(:delete_from_docker)
      container.destroy
      container.should_not be_persisted
    end
  end

  describe "#stop" do
    it "stops the remote instance" do
      container.host.docker.should_receive(:stop).with(container.instance_id)
      container.stop
      container.status.should eq "stopped"
    end
  end

  describe "#start" do
    it "starts the remote instance and then fetches and persists the port bindings" do
      container.host.docker.should_receive(:start).with(container.instance_id, "{\n        \"PortBindings\":{  },\n        \"Dns\": [\"8.8.8.8\"]\n      }")
      container.stub(:get_port_bindings).and_return("random port")
      container.start
      container.port_bindings.should eq "random port"
      container.status.should eq "started"
    end
  end
end
