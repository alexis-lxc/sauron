class ContainerHost < ActiveRecord::Base
  validates_presence_of :hostname, :ipaddress
  attr_reader :already_exists

  def register
    add_remote_response = Lxd.add_remote(self.ipaddress)
    if add_remote_response[:success]
      self.save unless record_exists?
      return self
    end
    self.errors.add(:remote_add, add_remote_response[:errors])
    return self
  end

  def self.reachable_node
    host = ContainerHost.find { |host| host.reachable? }
    if host.nil?
      raise Exception.new(msg='No Healthy LXD Cluster nodes available. Please try after adding a new node')
    end
    host.ipaddress
  end

  def reachable?
    begin
      lxd_client = Hyperkit::Client.new(api_endpoint: "https://#{self.ipaddress}:8443", verify_ssl: false, auto_sync: false)
      !lxd_client.operations.nil?
    rescue Exception => error
      false
    end
  end

  private

  def record_exists?
    @already_exists = ContainerHost.find_by(hostname: self.hostname, ipaddress: self.ipaddress).present?
    @already_exists
  end


end
