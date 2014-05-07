require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  it { should have_many :containers }

  it "has a #container_limit of 2" do
    user.container_limit.should eq 2
  end

  describe "#at_container_limit?" do
    specify { user.should_not be_at_container_limit }
    specify do
      user.stub(:containers) { [ nil, nil ] }
      user.should be_at_container_limit
    end
  end
end
