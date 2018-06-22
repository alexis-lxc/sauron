class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles, id: :bigint do |t|
      t.string :name, null: false
      t.text :ssh_authorized_keys, array:true, default: []
      t.string :cpu_limit
      t.string :memory_limit

      t.timestamps
    end
  end
end
