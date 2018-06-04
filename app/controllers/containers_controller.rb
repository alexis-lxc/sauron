class ContainersController < ApplicationController
  before_action :assign_attributes, only: [:create]

  def create
    container = Container.new(lxd_host_ipaddress: @lxd_host_ipaddress, image: @image, container_hostname: @container_hostname)
    unless container.valid?
      render json: {success: false, errors: container.errors.full_messages.join(',')}, status: :bad_request
      return
    end
    response = container.launch

    # Assign key pair if it's specified
    unless @key_pair_name.blank?
      # Give time for the container to start
      # TODO: @giosakti should find more predictable way
      sleep(5.seconds)
      key_pair = KeyPair.find_by!(name: @key_pair_name)
      response = Lxd.attach_public_key(@lxd_host_ipaddress, @container_hostname, key_pair.public_key)
    end

    return render json: response, status: :created if response[:success] == 'true'
    render json: response, status: :internal_server_error
  end

  def destroy
    container = Container.new(lxd_host_ipaddress: params[:lxd_host_ipaddress], container_hostname: params[:container_hostname])
    unless container.valid?
      render json: {success: false, errors: container.errors.full_messages.join(',')}, status: :bad_request
      return
    end
    response = Lxd.destroy_container(params[:lxd_host_ipaddress], params[:container_hostname])
    return redirect_to containers_path(lxd_host_ipaddress: params[:lxd_host_ipaddress]) if response[:success] == 'true'
    render json: response, status: :internal_server_error
  end

  def index
    @containers = Lxd.list_containers(params[:lxd_host_ipaddress], params[:lxd_hostname])
  end

  def show
    @container = Lxd.show_container(params[:lxd_host_ipaddress], params[:container_hostname])
    respond_to do |format|
      format.html
      format.json
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
    @lxd_host_ipaddress = params[:container][:lxd_host_ipaddress]
    @key_pair_name      = params[:container][:key_pair_name]
  end
end
