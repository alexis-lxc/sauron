class Profile
  include ActiveModel::Model
  attr_accessor :name, :ssh_authorized_keys, :cpu_limit, :memory_limit
  validates_presence_of :name
  validate :memory_limit_format
  validates_numericality_of :cpu_limit, allow_nil: true, greater_than: 0

  def create
    LxdProfile.create_from(from: 'default', to: self.name,
                           overrides: {:"limits.cpu" => self.cpu_limit,
                                        :"limits.memory" => self.memory_limit,
                                        :"ssh_authorized_keys" => self.ssh_authorized_keys})
  end

  def memory_limit_format
    if memory_limit.present? && /^[1-9][0-9]*($|kB|MB|GB|TB|EB)$/.match(memory_limit).nil?
       errors.add(:memory_limit, "Memory limit should be positive % or have suffix one of kB, MB, GB TB, PB or EB")
    end
  end

end
