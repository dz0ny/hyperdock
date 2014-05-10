require 'spec_helper'

describe Host do
  let(:host) { build(:host) }

  it { should have_many :containers }

  it "has a valid factory" do
    host.should be_valid
  end

  it "#docker returns a Docker object" do
    subject.docker.should be_a Docker
  end

  it "#info returns a display-ready string" do
    subject.info.should eq "None"
  end

  it "is valid if #get_info has key containers" do
    stub_get_info host
    host.get_info.should have_key "Containers"
    host.should be_valid
  end

  it "#info returns a pretty json string" do
    stub_get_info host
    host.info.should match /{\n  /
  end
end
