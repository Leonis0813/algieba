class CreateAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :accounts do |t|
      t.string :account_type
      t.date :date
      t.string :content
      t.string :category
      t.integer :price

      t.timestamps null: false
    end
  end
end
