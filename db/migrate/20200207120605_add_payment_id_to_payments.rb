class AddPaymentIdToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :payment_id, :string,
               null: false,
               default: '',
               after: :id

    Payment.where(payment_id: '').each do |payment|
      payment.update!(payment_id: SecureRandom.hex)
    end

    add_index :payments, :payment_id, unique: true
  end
end
