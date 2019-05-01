class CreateCategoriesPayments < ActiveRecord::Migration
  def change
    create_table :categories_payments, id: false do |t|
      t.references :category, index: true, null: false
      t.references :payment, index: true, null: false
    end

    add_index :categories_payments, %i[category_id payment_id], unique: true
  end
end
