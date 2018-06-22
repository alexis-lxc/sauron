class DropCreateProfiles < ActiveRecord::Migration[5.1]
  def change
    drop_table :profiles
  end
end
