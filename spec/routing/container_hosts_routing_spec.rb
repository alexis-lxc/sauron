require 'rails_helper'

RSpec.describe ContainerHostsController  do
  it "routes POST /container-hosts to container_host#create" do
    expect(:post => "/container-hosts").to route_to(
      :controller => "container_hosts",
      :action => "create"
    )
  end
  it "routes GET /container-hosts to container_host#index" do
    expect(:get => "/container-hosts").to route_to(
      :controller => "container_hosts",
      :action => "index"
    )
  end
  it "routes GET /container-hosts/:id to container_host#show" do
    expect(:get => "/container-hosts/1").to route_to(
      :controller => "container_hosts",
      :action => "show",
      :id => "1"
    )
  end
end
