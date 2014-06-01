class HostsController < AdminController
  before_action :set_host, only: [:show, :destroy, :healthcheck, :discard_zombie_container, :reclaim_zombie_container]
  before_action :set_cloud_options, only: [:new]

  # GET /hosts
  # GET /hosts.json
  def index
    @hosts = Host.all
  end

  # GET /hosts/1
  # GET /hosts/1.json
  def show
  end

  # GET /hosts/new
  def new
    @host = Host.new
  end

  # POST /hosts
  # POST /hosts.json
  def create
    @host = Host.new(host_params)

    respond_to do |format|
      if @host.save
        format.html { redirect_to @host, notice: 'Host was successfully created.' }
        format.json { render :show, status: :created, location: @host }
      else
        format.html { set_cloud_options ; render :new }
        format.json { render json: @host.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hosts/1
  # DELETE /hosts/1.json
  def destroy
    @host.destroy
    respond_to do |format|
      format.html { redirect_to hosts_url, notice: 'Host was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def healthcheck
    if @host.online?
      flash[:success] = "#{@host.name} is healthy"
      redirect_to :back
    else
      redirect_to :back, alert: "#{@host.name} is unhealthy"
    end
  end

  def reclaim_zombie_container
    c = OpenStruct.new @host.docker.inspect params[:instance_id]  
    image = Image.where(docker_index: c.Config["Image"]).first
    unless image
      exposed_ports = c.Config["ExposedPorts"].keys.join(',')
      image = Image.create(name: c.Config["Image"], port_bindings: exposed_ports)
    end
    container = current_user.containers.build({
      instance_id: c.ID,
      host: @host,
      region: @host.region,
      image: image,
      env_settings: Hash[c.Config["Env"].map {|pair| pair.split('=') }],
      port_bindings: c.NetworkSettings["Ports"].to_json,
      status: c.State["Running"] ? "started" : "stopped",
      name: "Reclaimed Container!"
    })
    if container.save
      flash[:success] = "Container reclaimed successfully!"
    else
      flash[:alert] = "Failed to reclaim container. #{container.errors.full_messages}"
    end
    redirect_to @host
  end

  def discard_zombie_container
    @host.docker.rm params[:instance_id]  
    flash[:success] = "Discarded zombie."
  rescue
    flash[:error] = "Failed to discard zombie!"
  ensure
    redirect_to @host
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_host
      @host = Host.find(params[:id])
    end

    def set_cloud_options
      @regions = Cloud.regions
      @vm_sizes = Cloud.vm_sizes
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def host_params
      params.require(:host).permit(:is_monitor, :digitalocean_region_id, :digitalocean_size_id)
    end
end
