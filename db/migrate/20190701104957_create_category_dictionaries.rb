class CreateCategoryDictionaries < ActiveRecord::Migration[4.2]
  def change
    create_table :category_dictionaries do |t|
      t.references :category, index: true, null: false
      t.references :dictionary, index: true, null: false

      t.timestamps null: false
    end

    add_index :category_dictionaries, %i[category_id dictionary_id], unique: true
  end
end
