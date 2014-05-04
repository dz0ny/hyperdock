class Container < ActiveRecord::Base
  belongs_to :region
  belongs_to :host
  belongs_to :image
  belongs_to :user

  before_destroy :delete_from_docker

  before_save :select_host

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

  def select_host
    # TODO: select most optimal host
    self.host = self.region.hosts.last
  end

  def get_info
    self.host.docker.inspect self.instance_id
  end

  def get_port_bindings
    self.get_info["NetworkSettings"]["Ports"].to_json
  end 

  def info
    JSON.pretty_generate(get_info) rescue "None"
  end

  def top
    JSON.pretty_generate(self.host.docker.top self.instance_id) rescue "None"
  end


  def start
    if self.port_bindings
      config = %{{
        "PortBindings": #{self.port_bindings} ,
        "Dns": ["8.8.8.8"]
      }}
    else
      config = %{{
        "PortBindings":{ #{self.image.port_bindings} },
        "Dns": ["8.8.8.8"]
      }}
    end
    self.host.docker.start self.instance_id, config
    self.update(status: "started", port_bindings: self.get_port_bindings)
  end

  def stop
    self.host.docker.stop self.instance_id
    self.update(status: "stopped")
  end

  def exposed_ports
    JSON.parse(self.port_bindings).values.map {|pair| pair[0]["HostPort"] }.join(', ') rescue "N/A"
  end

  private

  def delete_from_docker
    self.stop
    self.host.docker.rm self.instance_id
  end
end
