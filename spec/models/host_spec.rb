require 'spec_helper'

describe Host do
  it "#docker returns a Docker object" do
    subject.docker.should be_a Docker
  end
end
