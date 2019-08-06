class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps null: false
    end

    add_index :categories, :name, unique: true
  end
end
