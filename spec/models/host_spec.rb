require 'spec_helper'

describe Host do
  let(:host) { build(:host) }

  it "#docker returns a Docker object" do
    subject.docker.should be_a Docker
  end

  it "is invalid if #get_info is wrong" do
    stub_get_info host, false
    host.should_not be_valid
  end

  it "is valid if #get_info is right" do
    stub_get_info host
    host.should be_valid
  end
end
