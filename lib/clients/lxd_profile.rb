require 'hyperkit'
module LxdProfile
  extend self

  def create_from(from: 'default', to: 'copy', overrides: {})
    from_profile = get(from)
    begin
      client_object.create_profile(to, from_profile)
    rescue Hyperkit::Error => error
      return {success: 'false', error: error.as_json}
    end
    return {success: 'true', error: ''}
  end

  def get(name)
    begin
      profile = convert_response client_object.profile(name)
    rescue Hyperkit::Error => error
      return {success: 'false', error: error.as_json}
    end
    return {success: 'true', error: '', data: {profile: profile}}
  end

  private

  def convert_response(input)
    input[:config][:"user.network-config"] = YAML.load(input[:config][:"user.network-config"]).deep_symbolize_keys
    input[:config][:"user.user-data"] = YAML.load(input[:config][:"user.user-data"]).deep_symbolize_keys
    input
  end

  def client_object
    lxd_host_ipaddress = ContainerHost.first.ipaddress
    Hyperkit::Client.new(api_endpoint: "https://#{lxd_host_ipaddress}:8443", verify_ssl: false)
  end
end
