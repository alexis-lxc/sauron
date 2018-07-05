class Profile
  include ActiveModel::Model
  attr_accessor :name, :ssh_authorized_keys, :cpu_limit, :memory_limit
  validates_presence_of :name
  validate :memory_limit_format
  validates_numericality_of :cpu_limit, allow_nil: true, greater_than: 0

  def create
    response = LxdProfile.create_from(from: 'default', to: self.name,
                                      overrides: {:"limits.cpu" => self.cpu_limit,
                                                  :"limits.memory" => self.memory_limit,
                                                  :"ssh_authorized_keys" => self.ssh_authorized_keys})
    if response[:success] == 'false'
      self.errors.add(:response, response[:error])
      return false
    end
    return true
  end

  def get
    response = LxdProfile.get(self.name)
    if response[:success] == 'false'
      self.errors.add(:response, response[:error])
      return self
    end
    self.assign_attributes(cpu_limit: response[:data][:profile][:config][:"limits.cpu"],
                            memory_limit: response[:data][:profile][:config][:"limits.memory"],
                            ssh_authorized_keys: response[:data][:profile][:config][:"user.user-data"][:ssh_authorized_keys])
    return self
  end

  def update
    response = LxdProfile.update(self.name, {'limits.cpu': self.cpu_limit, 'limits.memory': self.memory_limit, 'ssh_authorized_keys': self.ssh_authorized_keys})
    if response[:success] == 'false'
      self.errors.add(:response, response[:error])
    end
      return self
  end

  def memory_limit_format
    if memory_limit.present? && /^[1-9][0-9]*($|kB|MB|GB|TB|EB)$/.match(memory_limit).nil?
      errors.add(:memory_limit, "Memory limit should be positive % or have suffix one of kB, MB, GB TB, PB or EB")
    end
  end

end
