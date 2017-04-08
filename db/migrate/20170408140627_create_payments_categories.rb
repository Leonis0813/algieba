class CreatePaymentsCategories < ActiveRecord::Migration
  def change
    create_table :payments_categories, :id => false do |t|
      t.references :payment, :index => true, :null => false
      t.references :category, :index => true, :null => false
    end
  end
end
