class StartContainer
  include Sidekiq::Worker
  sidekiq_options :retry => 5

  sidekiq_retry_in do |count|
    count + 1
  end

  def perform(container_name)
    container = client.container(container_name)
    start_interval = Time.now - container[:created_at]
    container_status = container[:status]
    count = 0
    if start_interval > Figaro.env.WAIT_INTERVAL_FOR_CONTAINER_OPERATIONS.to_i
      while container_status != "Running" || count == Figaro.env.MAX_RETRY.to_i
        sleep(Figaro.env.WAIT_INTERVAL_FOR_CONTAINER_OPERATIONS.to_i)
        res = client.start_container(container_name)
        container_detail = client.container_state(container_name)
        container_status = container_detail[:status]
        count += 1
        res
      end
    else
      raise Exception.new("Container #{container_name} is still being created")
    end
  end

  def client
    Lxd.client
  end
end
