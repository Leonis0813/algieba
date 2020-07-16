class ChangeDefaultNullToTags < ActiveRecord::Migration[5.0]
  def up
    change_column_null :tags, :name, true, nil
    change_column :tags, :name, :string, default: nil
  end

  def down
    change_column_null :tags, :name, false, ''
    change_column :tags, :name, :string, default: ''
  end
end
