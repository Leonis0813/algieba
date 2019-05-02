class AddIdToCategoryPayments < ActiveRecord::Migration
  def change
    add_column :category_payments, :id, :primary_key, first: true
  end
end
