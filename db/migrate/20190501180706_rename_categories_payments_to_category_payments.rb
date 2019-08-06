class RenameCategoriesPaymentsToCategoryPayments < ActiveRecord::Migration[4.2]
  def change
    rename_table :categories_payments, :category_payments
  end
end
