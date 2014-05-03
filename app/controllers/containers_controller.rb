class ContainersController < ApplicationController
  before_action :set_container, only: [:show, :edit, :update, :destroy]

  # GET /containers
  # GET /containers.json
  def index
    @containers = Container.all
  end

  # GET /containers/1
  # GET /containers/1.json
  def show
  end

  # GET /containers/new
  def new
    @images = Image.all
    @container = Container.new
  end

  # GET /containers/1/edit
  def edit
    @images= Image.all
  end

  # POST /containers
  # POST /containers.json
  def create
    @container = Container.new(container_params)
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

  def start
   
    @container = Container.find(params[:id])
    if @container.port_bindings
      json = %{{
        "PortBindings": #{@container.port_bindings} ,
        "Dns": ["8.8.8.8"]
      }}
    else
      json = %{{
        "PortBindings":{ #{@container.image.port_bindings} },
        "Dns": ["8.8.8.8"]
      }}
    end
    res = `curl -X POST -H "Content-Type: application/json" -d '#{json}' http://cry.li:5422/containers/#{@container.instance_id}/start`
    Rails.logger.info res
    @container.port_bindings = @container.get_port_bindings 
    @container.status = 'started'
    @container.save
    redirect_to @container
  end

  def stop
    @container =Container.find(params[:id])
    res = `curl -X POST http://cry.li:5422/containers/#{@container.instance_id}/stop?t=0`
    Rails.logger.info res
    @container.status = 'stopped'
    @container.save
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
    res = `curl -X POST http://cry.li:5422/containers/#{@container.instance_id}/stop?t=0`
    response2 = `curl -X DELETE /containers/#{@container.instance_id}?v=1`  
    Rails.logger.info res
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
      params.require(:container).permit(:image_id, :status, :name)
    end
end
