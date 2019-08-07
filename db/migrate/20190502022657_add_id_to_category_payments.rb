class AddIdToCategoryPayments < ActiveRecord::Migration[4.2]
  def change
    add_column :category_payments, :id, :primary_key, first: true
  end
end
