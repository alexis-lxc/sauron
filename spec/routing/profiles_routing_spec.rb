require 'rails_helper'

RSpec.describe ProfilesController  do
  it "routes POST /profiles to profiles#create" do
    expect(:post => "/profiles").to route_to(
      :controller => "profiles",
      :action => "create"
    )
  end
end
