Sidekiq.configure_server do |config|
  config.redis = { url: Figaro.env.sidekiq_redis_url }
  config.average_scheduled_poll_interval = Figaro.env.sidekiq_poll_interval.to_i

end

Sidekiq.configure_client do |config|
  config.redis = { url: Figaro.env.sidekiq_redis_url }
end
