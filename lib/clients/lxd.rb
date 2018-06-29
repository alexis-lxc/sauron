require 'hyperkit'
module Lxd
  extend self

  def add_remote(lxd_host_ipaddress)
    lxd = client_object(lxd_host_ipaddress)
    begin
      lxd.create_certificate(File.read(lxd.client_cert), password: 'ubuntu')
    rescue StandardError => error
      return {success: false, errors: error.to_s} unless error.to_s.include? "Certificate already in trust store"
    end
    return {success: true, errors: ''}
  end

  def list_containers(lxd_host_ipaddress, lxd_hostname)
    lxd = client_object(lxd_host_ipaddress)
    container_list = lxd.containers
    containers = []
    container_list.each do |container|
      containers << Container.new(lxd_hostname: lxd_hostname, container_hostname: container, lxd_host_ipaddress: lxd_host_ipaddress)
    end
    return containers
  end

  def show_container(lxd_host_ipaddress, container_name)
    lxd = client_object(lxd_host_ipaddress)
    container_details = lxd.container(container_name)
    container_state = lxd.container_state(container_name)
    ipaddress = container_state[:network][:eth0][:addresses].
      select{|x| x[:family] == 'inet'}.
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
  def launch_container(lxd_host_ipaddress, image, container_hostname)
    create_container_response = create_container(lxd_host_ipaddress, container_hostname)
    if create_container_response[:success] == 'true'
      response = start_container(lxd_host_ipaddress, container_hostname)
      return response
    end
    return create_container_response
  end

  def create_container(lxd_host_ipaddress, container_hostname)
    begin
      lxd = client_object(lxd_host_ipaddress)
      response = lxd.create_container(container_hostname, server: "https://cloud-images.ubuntu.com/releases", protocol: "simplestreams", alias: "16.04")
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success  = response[:status] == 'Running' ? 'true' : false
    return {success: success, error: response[:err]}
  end

  def start_container(lxd_host_ipaddress, container_hostname)
    begin
      lxd = client_object(lxd_host_ipaddress)
      response = lxd.start_container(container_hostname)
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success  = response[:status] == 'Running' ? 'true' : false
    return {success: success, error: response[:err]}
  end

  def destroy_container(lxd_host_ipaddress, container_hostname)
    stop_container_response = stop_container(lxd_host_ipaddress, container_hostname)
    if stop_container_response[:success] == 'true'
      delete_container_response = delete_container(lxd_host_ipaddress, container_hostname)
      return delete_container_response
    end
    return stop_container_response
  end

  def delete_container(lxd_host_ipaddress, container_hostname)
    lxd = client_object(lxd_host_ipaddress)
    begin
      response = lxd.delete_container(container_hostname)
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success  = response[:status] == 'Success' ? 'true' : false
    return {success: success, error: response[:err]}
  end

  def stop_container(lxd_host_ipaddress, container_hostname)
    lxd = client_object(lxd_host_ipaddress)
    begin
      response = lxd.stop_container(container_hostname)
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success  = response[:status] == 'Success' ? 'true' : false
    return {success: success, error: response[:err]}
  end

  def attach_public_key(lxd_host_ipaddress, container_hostname, public_key, opts = {})
    lxd = client_object(lxd_host_ipaddress)
    username = opts[:username] || 'ubuntu'

    begin
      response = lxd.execute_command(container_hostname,
        "bash -c 'echo \"#{public_key}\" > /home/#{username}/.ssh/authorized_keys'"
      )
    rescue Hyperkit::Error => error
      return {success: false, error: error.as_json}
    end
    success  = response[:status] == 'Success' ? 'true' : false
    return {success: success, error: response[:err]}
  end

  def client_object(lxd_host_ipaddress)
    Hyperkit::Client.new(api_endpoint: "https://#{lxd_host_ipaddress}:8443", verify_ssl: false, auto_sync: false)
  end
end
