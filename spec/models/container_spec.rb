require 'spec_helper'

describe Container do
  it { should validate_presence_of :name }
  let(:container) { build(:container) }

  it { should belong_to :region }
  it { should belong_to :host }
  it { should belong_to :image }
  it { should belong_to :user }

  it { should serialize(:env_settings).as(Hash) }

  describe "factory" do
    subject { container }
    it { should be_valid }   
  end

  it "it gets assigned the host when saved" do
    container.save
    container.host.should be_a Host
    container.region.hosts.last.id.should eq container.host.id
  end

  it "#get_info uses docker api to inspect the container" do
    container.save
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
      container.save
      container.host.docker.should_receive(:stop).with(container.instance_id)
      container.stop
      container.status.should eq "stopped"
    end
  end

  describe "#start" do
    it "starts the remote instance and then fetches and persists the port bindings" do
      container.save
      container.host.docker.should_receive(:start).with(container.instance_id, {:PortBindings=>{}, :Dns=>["8.8.8.8"]})
      container.stub(:get_port_bindings).and_return("random port")
      container.start
      container.port_bindings.should eq "random port"
      container.status.should eq "started"
    end
  end

  describe "#config" do
    subject { container.config }
    it { should have_key :for_start }
    it { should have_key :for_create }
  end


  describe "#save container that lost association with an image" do
    before(:each) do
      container.save
      container.image.destroy
      container.reload
      container.stub(:get_info).and_return({
        "Config"=>{
          "Image"=> "a-nice-name",
          "ExposedPorts" => {
            "22/tcp" => {},
            "3000/tcp" => {}
          }
        },
        "Image"=>"a-uuid"
      })
      container.save
    end
    it "can be saved without raising errors" do
      container.errors.should be_empty
    end
    specify "because a new image get linked from the Docker info" do
      container.image.should be_persisted
    end
  end
end
