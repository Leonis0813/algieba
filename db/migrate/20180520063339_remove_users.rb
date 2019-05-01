class RemoveUsers < ActiveRecord::Migration
  def up
    drop_table :users
  end

  def down
    create_table :users do |t|
      t.string :user_id
      t.string :password

      t.timestamps
    end
  end
end
