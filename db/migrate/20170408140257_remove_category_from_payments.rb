class RemoveCategoryFromPayments < ActiveRecord::Migration[4.2]
  def up
    remove_column :payments, :category
  end

  def down
    add_column :payments, :category, :string, after: :content
  end
end
