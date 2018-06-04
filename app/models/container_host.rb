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

  private

  def record_exists?
    @already_exists = ContainerHost.find_by(hostname: self.hostname, ipaddress: self.ipaddress).present?
    @already_exists
  end
end
