require 'spec_helper'

describe Container do
  let(:host) { build(:host) }
  let(:container) { create(:container, host: host) }

  before(:each) do
    stub_get_info host
  end

  it "spec_name" do
    stub_get_info container
    container.get_info.should be_a Hash
  end
end
