class RemoveCategoryFromPayments < ActiveRecord::Migration
  def change
    remove_column :payments, :category
  end
end
