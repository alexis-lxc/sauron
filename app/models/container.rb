class Container
  include ActiveModel::Model
  attr_accessor :lxd_hostname, :lxd_host_ipaddress, :container_hostname, :image, :ipaddress, :status, :created_at, :lxc_profiles, :key_pair_name
  validates_presence_of :container_hostname, :lxd_host_ipaddress

  def launch
    self.image = 'ubuntu:16.04' if self.image.blank?
    Lxd.launch_container(self.lxd_host_ipaddress, self.image, self.container_hostname)
  end

end
