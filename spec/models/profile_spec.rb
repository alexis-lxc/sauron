require 'rails_helper'

RSpec.describe Profile do
  it { should validate_presence_of(:name) }
end
