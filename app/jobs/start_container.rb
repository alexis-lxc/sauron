class StartContainer
  include Sidekiq::Worker
  def perform(container_name)
    client.start_container(container_name)
  end

  def client
    Lxd.client
  end
end
