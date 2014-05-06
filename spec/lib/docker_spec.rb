require 'spec_helper'
require 'docker'

describe Docker do
  let(:region) { create(:region) }
  let(:host) { create(:host, region: region ) }
  let(:container) { create(:container, host: host, region: region) }
  let(:api) { container.host.docker }

  describe "HTTP API" do

    it "can start a container over HTTP" do
      stub_docker_start container, "my config"
      api.start container.instance_id, "my config"
    end
  end
end
