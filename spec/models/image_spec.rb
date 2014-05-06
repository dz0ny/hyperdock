require 'spec_helper'

describe Image do
  let(:image) { build(:image) }

  #it "#docker_index must exist on the official docker index" do
  #  image.docker_index = "invalid"
  #  image.should_not be_valid

  #  image.docker_index = "valid"
  #  image.should be_valid
  #end

  describe "#format_port_bindings" do
    it "converts comma separated list of ports to initial docker PortBindings value" do
      image.port_bindings = "22 ,80, 8080"
      image.format_port_bindings
      image.port_bindings.should eq "\"22/tcp\": [{ \"HostIp\": \"0.0.0.0\", \"HostPort\": \"0\" }],\"80/tcp\": [{ \"HostIp\": \"0.0.0.0\", \"HostPort\": \"0\" }],\"8080/tcp\": [{ \"HostIp\": \"0.0.0.0\", \"HostPort\": \"0\" }]"
    end

    it "supports explicit udp and tcp" do
      image.port_bindings = "22 ,80/tcp, 8080/udp"
      image.format_port_bindings
      image.port_bindings.should eq "\"22/tcp\": [{ \"HostIp\": \"0.0.0.0\", \"HostPort\": \"0\" }],\"80/tcp\": [{ \"HostIp\": \"0.0.0.0\", \"HostPort\": \"0\" }],\"8080/udp\": [{ \"HostIp\": \"0.0.0.0\", \"HostPort\": \"0\" }]"
    end
  end

end
