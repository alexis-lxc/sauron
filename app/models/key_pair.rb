class KeyPair < ApplicationRecord
  validates_presence_of :name, :public_key
  validates_uniqueness_of :name
  validates_length_of :name, :minimum => 3, :allow_blank => true
end
