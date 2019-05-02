class RenameCategoriesPaymentsToCategoryPayments < ActiveRecord::Migration
  def change
    rename_table :categories_payments, :category_payments
  end
end
