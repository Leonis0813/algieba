class RenameAccountTypeToPaymentType < ActiveRecord::Migration
  def change
    rename_column :payments, :account_type, :payment_type
  end
end
