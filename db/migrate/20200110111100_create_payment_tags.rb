class CreatePaymentTags < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_tags do |t|
      t.references :payment, index: true, null: false
      t.references :tag, index: true, null: false

      t.timestamps null: false
    end

    add_index :payment_tags, %i[payment_id tag_id], unique: true
  end
end
