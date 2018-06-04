class ContainerHostsController < ApplicationController
  def create
    container_host = ContainerHost.new(hostname: params[:hostname], ipaddress: params[:ipaddress])
    unless container_host.valid? && container_host.register
      render json: {errors: container_host.errors.full_messages.join(',')}, status: :bad_request
      return
    end
    if container_host.already_exists
      render json: {message: 'Lxd host already registered'}, status: :ok
      return
    end
    head :created
  end

  def index
    @container_hosts = ContainerHost.all
  end

  def show
    @container_host = ContainerHost.find_by(id: params[:id])
  end
end
