require 'spec_helper'
require 'docker/client'

describe Docker::Client do
  let(:container) { create(:container) }
  let(:api) { container.host.docker }
end
