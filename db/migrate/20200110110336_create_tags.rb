class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :tag_id, null: false, default: ''
      t.string :name, null: false, default: ''

      t.timestamps null: false
    end
  end
end
