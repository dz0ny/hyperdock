class Container < ActiveRecord::Base
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

  def info
    json = JSON.parse `curl http://cry.li:5422/containers/#{self.instance_id}/json`
    JSON.pretty_generate(json);
  end
end
