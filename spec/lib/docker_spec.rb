require 'spec_helper'
require 'docker'

describe Docker do
  let(:api) { host.docker }
  let(:host) { build(:host) }
  let(:container) { create(:container, host: host) }
  before(:each) { stub_get_info host }

  describe "HTTP API" do

    it "can start a container over HTTP" do
      stub_docker_start container, "my config"
      api.start container.instance_id, "my config"
    end
  end
end
