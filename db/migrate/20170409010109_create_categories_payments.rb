class CreateCategoriesPayments < ActiveRecord::Migration
  def change
    create_table :categories_payments, :id => false do |t|
      t.references :category, :index => true, :null => false
      t.references :payment, :index => true, :null => false
    end
  end
end
