class HealthCheckController < ActionController::Base
  def ping
    render json: {ping: 'pong'}, status: :ok
  end
end
