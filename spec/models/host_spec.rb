require 'spec_helper'

describe Host do
  let(:host) { build(:host) }

  it "#docker returns a Docker object" do
    subject.docker.should be_a Docker
  end

  it "is invalid if #get_info does not have key containers" do
    stub_get_info host, false
    host.get_info.should_not have_key "Containers"
    host.should_not be_valid
  end

  it "is valid if #get_info has key containers" do
    stub_get_info host
    host.get_info.should have_key "Containers"
    host.should be_valid
  end
end
