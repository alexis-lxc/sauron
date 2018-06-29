require 'hyperkit'
module LxdProfile
  extend self

  def create_from(from: 'default', to:, overrides: {})
    begin
      from_profile = yaml_to_hash(client_object.profile(from))
      from_profile[:config][:"user.user-data"] = from_profile[:config][:"user.user-data"].merge({ssh_authorized_keys: overrides[:"ssh_authorized_keys"]})
      from_profile[:config] = from_profile[:config].merge(overrides.except(:"ssh_authorized_keys"))
      from_profile = string_to_yaml(from_profile)
      client_object.create_profile(to, from_profile)
    rescue Hyperkit::Error => error
      return {success: 'false', error: error.as_json}
    end
    return {success: 'true', error: ''}
  end

  def get(name)
    begin
      profile = yaml_to_hash(client_object.profile(name))
    rescue Hyperkit::Error => error
      return {success: 'false', error: error.as_json}
    end
    return {success: 'true', error: '', data: {profile: profile}}
  end

  def update(name, attributes)
    begin
      client_object.patch_profile(name, attributes)
    rescue Hyperkit::Error => error
      return {success: 'false', error: error.as_json}
    end
    {success: 'true', error: ''}
  end

  private

  def string_to_yaml(input)
    input[:config][:"user.network-config"] = input[:config][:"user.network-config"].to_yaml
    input[:config][:"user.user-data"] = input[:config][:"user.user-data"].to_yaml
    input[:config][:"user.user-data"] = input[:config][:"user.user-data"].gsub(/---/, '#cloud-config')
    input
  end

  def yaml_to_hash(input)
    input[:config][:"user.network-config"] = YAML.load(input[:config][:"user.network-config"]).deep_symbolize_keys
    input[:config][:"user.user-data"] = YAML.load(input[:config][:"user.user-data"]).deep_symbolize_keys
    input.to_h
  end

  def client_object
    lxd_host_ipaddress = ContainerHost.first.ipaddress
    Hyperkit::Client.new(api_endpoint: "https://#{lxd_host_ipaddress}:8443", verify_ssl: false)
  end
end
