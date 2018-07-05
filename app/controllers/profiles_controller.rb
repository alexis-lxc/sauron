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

  def update
    @profile = Profile.new(name: profile_params[:name], cpu_limit: profile_params[:cpu_limit],
                          memory_limit: profile_params[:memory_limit],
                          ssh_authorized_keys: profile_params[:ssh_authorized_keys])
    unless @profile.valid? && @profile.update.errors.blank?
      flash[:message] = "Edit failed #{@profile.errors.full_messages.join(',')}"
      render action: :edit
      return
    end
    flash[:message] = 'Edit Done'
    render action: :show
  end

  private

  def profile_params
    params.require(:profile).permit(:name, :memory_limit, :cpu_limit, :ssh_authorized_keys)
  end
end
