require 'spec_helper'
require 'docker'

describe Docker do
  let(:container) { create(:container) }
  let(:api) { container.host.docker }

  describe "HTTP API" do

    it "can start a container over HTTP" do
      stub_docker_start container, "my config"
      lambda { api.start container.instance_id, "my config" }.should_not raise_error
    end
  end
end
