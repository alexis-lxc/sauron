require 'rails_helper'

RSpec.describe HealthCheckController  do
  it "routes /ping to healthchecks#ping" do
    expect(:get => "/ping").to route_to(
      :controller => "health_check",
      :action => "ping"
    )
  end
end
