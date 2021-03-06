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

  it 'routes GET /profiles/default to profiles#show' do
    expect(:get => '/profiles/default').to route_to(
      :controller => 'profiles',
      :action => 'show',
      :name => 'default'
    )
  end

  it 'routes PATCH /profiles/default to profiles#update' do
    expect(:patch => '/profiles/default').to route_to(
      :controller => 'profiles',
      :action => 'update',
      :name => 'default'
    )
  end

  it 'routes GET /profiles/new to profiles#new' do
    expect(:get => '/profiles/new').to route_to(
      :controller => 'profiles',
      :action => 'new'
    )
  end

  it 'routes GET /profiles/:name/edit to profiles#edit' do
    expect(:get => '/profiles/default/edit').to route_to(
      :controller => 'profiles',
      :action => 'edit',
      :name => 'default'
    )
  end
end
