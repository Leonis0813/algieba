class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :application_id
      t.string :application_key

      t.timestamps
    end
  end
end
