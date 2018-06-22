class Profile
  include ActiveModel::Model
  attr_accessor :name, :ssh_authorized_keys, :cpu_limit, :memory_limit
  validates_presence_of :name
end
