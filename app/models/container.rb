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

  before_validation :relink_image!

  def relink_image!
    if self.persisted? && self.image.nil?
      info = OpenStruct.new(self.get_info)
      image_name = info.Config["Image"]
      image_uuid = info.Image
      img = Image.where(docker_index: image_name).first
      unless img
        exposed_ports = info.Config["ExposedPorts"].keys.join(',')
        img = Image.create({
          name: image_name,
          description: image_uuid,
          docker_index: nil,
          port_bindings: exposed_ports
        })
      end
      self.image = img
    end
  rescue => ex
    self.errors.add(:image, "failed to relink! You should probably snapshot and destroy this container. If snapshotting hasn't been implemented yet and you're seeing this, please email us!") # FIXME shorten this notice once snapshotting is added
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
      self.host = self.region.hosts.where(is_monitor: false).first
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
