require 'spec_helper'

describe Provisioner do
  let(:worker) { Provisioner.new }
  let(:container) { create(:container) }

  before(:each) do
    Docker::Client.any_instance.stub(:pull)
    Docker::Client.any_instance.stub(:create).and_return("Warnings"=>nil)
  end

  it "sets an instance id" do
    prev_id = container.instance_id
    worker.perform('Container', container.id)
    container.reload.instance_id.should_not eq prev_id
  end

  it "sets a status" do
    container.status.should_not eq "created"
    worker.perform('Container', container.id)
    container.reload.status.should eq "created"
  end
end
