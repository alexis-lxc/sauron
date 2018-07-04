class ProfilesController < ApplicationController
  def create
    profile = Profile.new(profile_params)
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

  def edit
    @profile = Profile.new(name: params[:name]).get
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :memory_limit, :cpu_limit, :ssh_authorized_keys)
  end
end
