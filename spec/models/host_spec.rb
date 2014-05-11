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
end
