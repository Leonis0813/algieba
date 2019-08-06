class RenameAccountTypeToPaymentType < ActiveRecord::Migration[4.2]
  def change
    rename_column :payments, :account_type, :payment_type
  end
end
