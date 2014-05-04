require 'spec_helper'

describe Host do
  let(:host) { create(:host) }

  it "#docker returns a Docker object" do
    subject.docker.should be_a Docker
  end

  it "#get_info returns docker host info" do
    host.get_info.should have_key "Containers"
  end
end
