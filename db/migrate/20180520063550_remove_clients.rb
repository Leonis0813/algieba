class RemoveClients < ActiveRecord::Migration
  def up
    drop_table :clients
  end

  def down
    create_table :clients do |t|
      t.string :application_id
      t.string :application_key

      t.timestamps
    end
  end
end
