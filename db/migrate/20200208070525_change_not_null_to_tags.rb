class ChangeNotNullToTags < ActiveRecord::Migration[5.0]
  def up
    change_column_null :tags, :tag_id, true, nil
    change_column :tags, :tag_id, :string, default: nil
  end

  def down
    change_column_null :tags, :tag_id, false, ''
    change_column :tags, :tag_id, :string, default: ''
  end
end
