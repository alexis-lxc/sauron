require 'rails_helper'

RSpec.describe ProfilesController  do
  it 'routes POST /profiles to profiles#create' do
    expect(:post => '/profiles').to route_to(
      :controller => 'profiles',
      :action => 'create'
    )
  end

  it 'routes GET /profiles to profiles#index' do
    expect(:get => '/profiles').to route_to(
      :controller => 'profiles',
      :action => 'index'
    )
  end

  it 'routes GET /profile/default to profiles#show' do
    expect(:get => '/profile/default').to route_to(
      :controller => 'profiles',
      :action => 'show',
      :name => 'default'
    )
  end
end
