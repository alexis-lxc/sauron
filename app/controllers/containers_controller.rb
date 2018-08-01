class ContainersController < ApplicationController
  before_action :assign_attributes, only: [:create]

  def create
    container = Container.new(image: @image, container_hostname: @container_hostname)
    unless container.valid?
      render json: {success: false, errors: container.errors.full_messages.join(',')}, status: :bad_request
      return
    end
    response = container.launch

    return render json: response, status: :created if response[:success] == 'true'
    render json: response, status: :internal_server_error
  end

  def destroy
    container = Container.new(container_hostname: params[:container_hostname])
    unless container.valid?
      render json: {success: false, errors: container.errors.full_messages.join(',')}, status: :bad_request
      return
    end
    response = Lxd.destroy_container(params[:container_hostname])
    respond_to do |format|
      if response[:success] == 'true'
        format.html { redirect_to containers_path(lxd_host_ipaddress: params[:lxd_host_ipaddress]) }
        format.json { render json: response }
      else
        format.html {
          redirect_to containers_path(lxd_host_ipaddress: params[:lxd_host_ipaddress]),
          :notice => response[:error]
        }
        format.json { render json: response, status: :internal_server_error }
      end
    end
  end

  def index
    @containers = Lxd.list_containers
  end

  def show
    @container = Lxd.show_container(params[:container_hostname])
    respond_to do |format|
      if @container[:success]
        format.html
        format.json
      else
        format.json{ render :json => @container, :status => 500 }
      end
    end
  end

  def new
    @container = Container.new
    @key_pairs = KeyPair.all
  end

  private

  def assign_attributes
    @image              = params[:container][:image]
    @container_hostname = params[:container][:container_hostname]
    @key_pair_name      = params[:container][:key_pair_name]
  end
end
