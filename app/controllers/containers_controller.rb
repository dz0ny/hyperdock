class ContainersController < AdminController
  before_action :set_container, only: [:show, :edit, :update, :destroy]
  before_action :set_form_requirements, only: [:new, :edit, :create]
  
  # GET /containers
  # GET /containers.json
  def index
    @containers = current_user.containers
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
  end

  # GET /containers/new
  def new
    if @regions.empty?
      redirect_to :back, alert: "We have reached our capacity! We will notify you as soon as we have provisioned additional resources! Thank you!"
    end
  end

  # GET /containers/1/edit
  def edit
  end

  # POST /containers
  # POST /containers.json
  def create
    if current_user.at_container_limit?
      msg = "You are limited to #{current_user.container_limit} containers. You may upgrade or destroy an existing container and try again."
      respond_to do |format|
        format.html { redirect_to containers_path, alert: msg }
        format.json { render json: {error: msg}, status: :forbidden }
      end
    else
      @container = current_user.containers.build(container_params)
      @container.status = 'pending'

      respond_to do |format|
        if @container.save
          # send to sidekiq to provision
          Provisioner.perform_async(@container.id) 
          format.html { redirect_to @container, notice: 'Container was successfully created.' }
          format.json { render :show, status: :created, location: @container }
        else
          format.html { render :new }
          format.json { render json: @container.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def start
    @container = Container.find(params[:id])
    redirect_to @container, notice: "Container has been started"
  rescue => ex
    redirect_to @container, alert: "#{ex.class.to_s} #{ex.message}"
  end

  def stop
    @container = Container.find(params[:id])
    @container.stop
    redirect_to @container
  end

  def restart 
    @container = Container.find(params[:id])
    @container.restart
    redirect_to @container
  end


  # PATCH/PUT /containers/1
  # PATCH/PUT /containers/1.json
  def update
    respond_to do |format|
      if @container.update(container_params)
        format.html { redirect_to @container, notice: 'Container was successfully updated.' }
        format.json { render :show, status: :ok, location: @container }
      else
        format.html { render :edit }
        format.json { render json: @container.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /containers/1
  # DELETE /containers/1.json
  def destroy
    @container.destroy
    # What if i couldn't delete from docker?
    respond_to do |format|
      format.html { redirect_to containers_url, notice: 'Container was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_container
      @container = Container.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def container_params
      params.require(:container).permit(:image_id, :region_id, :status, :name, env_settings: image_env.keys)
    end

    def image_env
      Image.find(params[:container][:image_id]).env_defaults rescue {}
    end

    def set_form_requirements
      @regions = Region.all_available
      @images = Image.all
      @container = Container.new
    end
end
