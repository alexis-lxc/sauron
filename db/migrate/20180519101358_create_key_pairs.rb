class CreateKeyPairs < ActiveRecord::Migration[5.1]
  def change
    create_table :key_pairs do |t|
      t.string :name,       null: false
      t.string :public_key, null: false
      t.string :fingerprint

      t.timestamps
    end
  end
end
