class Container < ActiveRecord::Base
  belongs_to :region
  belongs_to :host
  belongs_to :image
  belongs_to :user

  serialize :env_settings, Hash

  before_destroy :delete_from_docker

  before_save :select_host

  validates :name, presence: true
  validates :region, presence: true
  validates :image, presence: true

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
    self.host.docker.start(self.instance_id, config[:for_start])
    self.update(status: "started", port_bindings: self.get_port_bindings)
  end

  def stop
    self.host.docker.stop self.instance_id
    self.update(status: "stopped")
  end

  def restart
    self.host.docker.restart self.instance_id
    self.update(status: "started")
  end

  def config
    pb = self.port_bindings ? self.port_bindings : self.image.port_bindings
    { for_create: {
        Env: env_settings.map{|k,v| "#{k}=#{v}" },
        Image: self.image.docker_index },
      for_start: {
        PortBindings: JSON.parse(pb[0] == "{" ? pb : "{#{pb}}"),
        Dns: ['8.8.8.8'] } }
  end

  private

  def select_host
    unless self.host
      # TODO: select most optimal host
      self.host = self.region.hosts.last
    end
  end

  def delete_from_docker
    if self.host && self.host.online?
      begin
        self.stop
        self.host.docker.rm self.instance_id
      rescue Docker::Client::InvalidInstanceIdError
        # The container was never created
      end
    end
  end
end
