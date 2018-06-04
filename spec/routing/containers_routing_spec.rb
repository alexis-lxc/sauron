require 'rails_helper'

RSpec.describe ContainersController  do
  it "routes POST /containers to containers#create" do
    expect(:post => "/containers").to route_to(
      :controller => "containers",
      :action => "create"
    )
  end
  it "routes GET /containers to containers#index" do
    expect(:get => "/containers", :lxd_hostname => "p-lxc-01", :lxd_host_ipaddress => "172.16.1.2").to route_to(
      :controller => "containers",
      :action => "index"
    )
  end
  it "routes GET /container to containers#show" do
    expect(:get => "/container", :container_hostname => "p-user-service-01", :lxd_host_ipaddress => "172.16.1.2").to route_to(
      :controller => "containers",
      :action => "show"
    )
  end
  it "routes GET /containers/new to containers#new" do
    expect(:get => "/containers/new").to route_to(
      :controller => "containers",
      :action => "new"
    )
  end
  it "routes DELETE /containers to containers#destroy" do
    expect(:delete => "/containers").to route_to(
      :controller => "containers",
      :action => "destroy"
    )
  end
end
