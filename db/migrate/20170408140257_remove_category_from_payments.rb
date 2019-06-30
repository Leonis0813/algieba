class RemoveCategoryFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :category
  end

  def down
    add_column :payments, :category, :string, after: :content
  end
end
