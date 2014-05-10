require 'spec_helper'
require 'docker'

describe Docker do
  let(:container) { create(:container) }
  let(:api) { container.host.docker }
end
