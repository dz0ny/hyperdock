class Container < ActiveRecord::Base
  belongs_to :host
  belongs_to :image

  def config
    json = %{{
         "Hostname":"",
         "User":"",
         "Memory":0,
         "MemorySwap":0,
         "AttachStdin":false,
         "AttachStdout":true,
         "AttachStderr":true,
         "PortSpecs":null,
         "Tty":false,
         "OpenStdin":false,
         "StdinOnce":false,
         "Env":null,
         "Cmd":"",
         "Image":"#{self.image.docker_index}",
         "Volumes":{},
         "WorkingDir":"",
         "NetworkDisabled": false,
         "ExposedPorts":{}
      }}
  end

  def get_info
    self.host.docker.container_info self.instance_id
  end

  def get_port_bindings
    self.get_info["NetworkSettings"]["Ports"].to_json
  end 

  def info
    JSON.pretty_generate(get_info) rescue "None"
  end
end
