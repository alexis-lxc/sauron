class KeyPairsController < ApplicationController
  before_action :set_key_pair, only: [:show, :destroy]

  def index
    @key_pairs = KeyPair.all
  end

  def show
  end

  def new
    @key_pair = KeyPair.new
  end

  def create
    @key_pair = KeyPair.new(key_pair_params)

    if @key_pair.public_key.present?
      # Calculate fingerprint
      @key_pair.fingerprint = OpenSSL::Digest::SHA1.new(@key_pair.public_key)
      @key_pair.fingerprint = @key_pair.fingerprint.scan(/../).map{ |s| s.upcase }.join(":")
    else
      # Generate key and assign it into key pair
      generated_key = SSHKey.generate
      @key_pair.public_key = generated_key.ssh_public_key
      @key_pair.fingerprint = generated_key.sha1_fingerprint
    end

    respond_to do |format|
      if @key_pair.save
        format.html { redirect_to key_pair_path(@key_pair.id), notice: 'Key pair was successfully created.', flash: {private_key: generated_key.try(:private_key)} }
      else
        format.html { render :new }
      end
    end
  end

  def destroy
    @key_pair.destroy

    respond_to do |format|
      format.html { redirect_to key_pairs_url, notice: 'Key pair was successfully destroyed.' }
    end
  end

  private
    def set_key_pair
      @key_pair = KeyPair.find(params[:id])
    end

    def key_pair_params
      params.require(:key_pair).permit(:name, :public_key)
    end
end
