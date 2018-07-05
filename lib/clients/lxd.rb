require 'hyperkit'
module Lxd
  extend self

  def add_remote(lxd_host_ipaddress)
    lxd = client(lxd_host_ipaddress)
    begin
      lxd.create_certificate(File.read(lxd.client_cert), password: 'ubuntu')
    rescue StandardError => error
      return {success: false, errors: error.to_s} unless error.to_s.include? "Certificate already in trust store"
    end
    {success: true, errors: ''}
  end

  def list_containers
    container_list = client.containers
    container_list.map {|container| Container.new(container_hostname: container)}
  end

  def show_container(container_name)
    container_details = client.container(container_name)
    container_state = client.container_state(container_name)
    ipaddress = container_state[:network][:eth0][:addresses].
        select {|x| x[:family] == 'inet'}.
        first[:address]
    Container.new(
        container_hostname: container_name,
        status: container_state[:status],
        ipaddress: ipaddress,
        image: container_details[:config][:"image.description"],
        lxc_profiles: container_details[:profiles],
        created_at: container_details[:created_at]
    )
  end

  #does not honour image param, will launch 16.04 by default for now.
  def launch_container(image, container_hostname)
    create_container_response = create_container(container_hostname)
    if create_container_response[:success] == 'true'
      StartContainer.perform_in(Figaro.env.WAIT_INTERVAL_FOR_CONTAINER_OPERATIONS, container_hostname)
    end
    create_container_response
  end

  def create_container(container_hostname)
    begin
      response = client.create_container(container_hostname, server: "https://cloud-images.ubuntu.com/releases", protocol: "simplestreams", alias: "16.04")
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success = response[:status] == 'Running' ? 'true' : false
    {success: success, error: response[:err]}
  end

  def start_container(container_hostname)
    begin
      response = client.start_container(container_hostname)
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success = response[:status] == 'Running' ? 'true' : false
    {success: success, error: response[:err]}
  end

  def destroy_container(container_hostname)
    stop_container_response = stop_container(container_hostname)
    if stop_container_response[:success] == 'true'
      DeleteContainer.perform_in(Figaro.env.WAIT_INTERVAL_FOR_CONTAINER_OPERATIONS, container_hostname)
    end
    stop_container_response
  end

  def stop_container(container_hostname)
    begin
      response = client.stop_container(container_hostname)
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success = response[:status] == 'Running' ? 'true' : false
    {success: success, error: response[:err]}
  end

  def attach_public_key(container_hostname, public_key, opts = {})
    username = opts[:username] || 'ubuntu'

    begin
      response = client.execute_command(container_hostname,
                                        "bash -c 'echo \"#{public_key}\" > /home/#{username}/.ssh/authorized_keys'"
      )
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success = response[:status] == 'Success' ? 'true' : false
    {success: success, error: response[:err]}
  end

  def client(lxd_host_ipaddress = ContainerHost.reachable_node)
    Hyperkit::Client.new(api_endpoint: "https://#{lxd_host_ipaddress}:8443", verify_ssl: false, auto_sync: false)
  end

end
