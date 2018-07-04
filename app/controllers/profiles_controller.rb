class ProfilesController < ApplicationController
  def create
    profile = Profile.new(name: params[:name], ssh_authorized_keys: params[:ssh_authorized_keys],
                          cpu_limit: params[:cpu_limit], memory_limit: params[:memory_limit])
    unless profile.valid?
      render json: {success: false, errors: profile.errors.full_messages.join(',')}, status: :bad_request
      return
    end

    unless profile.create
      render json: {success: false, errors: profile.errors.full_messages.join(',')}, status: :server_error
      return
    end
    render json: {success: true, errors: ''}, status: :created
  end

  def index
    @profiles = LxdProfile.get_all[:data][:profiles]
  end

  def show
    @profile = Profile.new(name: params[:name]).get
  end

  def new
    @profile = Profile.new
  end

end
