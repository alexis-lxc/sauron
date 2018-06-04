require 'rails_helper'

RSpec.describe HealthCheckController do
  describe 'GET#ping' do
    it 'should return pong for ping health check requests' do
      get :ping
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)).to eq({"ping"=>"pong"})
    end
  end
end
