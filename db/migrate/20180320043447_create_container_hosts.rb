class CreateContainerHosts < ActiveRecord::Migration[5.1]
  def up
    create_table :container_hosts, id: :bigint do |t|
      t.string :hostname
      t.string :ipaddress

      t.timestamps
    end
  end

  def down
    drop_table :container_hosts
  end
end
