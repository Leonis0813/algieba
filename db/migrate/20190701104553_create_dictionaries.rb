class CreateDictionaries < ActiveRecord::Migration[4.2]
  def change
    create_table :dictionaries do |t|
      t.string :phrase, null: false
      t.string :condition, null: false

      t.timestamps null: false
    end

    add_index :dictionaries, %i[phrase condition], unique: true
  end
end
