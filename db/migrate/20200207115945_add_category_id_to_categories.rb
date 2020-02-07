class AddCategoryIdToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :category_id, :string,
               null: false,
               default: '',
               after: :id

    Category.where(category_id: '').each do |category|
      category.update!(category_id: SecureRandom.hex)
    end

    add_index :categories, :category_id, unique: true
  end
end
