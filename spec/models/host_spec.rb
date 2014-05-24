require 'spec_helper'

describe Host do
  let(:host) { build(:host) }

  it { should have_many :containers }

  it "has a valid factory" do
    host.should be_valid
  end

  it "#docker returns a Docker object" do
    subject.docker.should be_a Docker::Client
  end

  it "is not a monitor by default" do
    host.should_not be_monitor
  end

  it "can be a monitor" do
    host.save
    host.is_monitor!
    host.reload.should be_monitor
  end

  it "has a temporary storage directory on disk created as needed" do
    host.save
    host.tmp.should be_directory
  end
end
