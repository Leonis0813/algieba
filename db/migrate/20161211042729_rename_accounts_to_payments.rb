class RenameAccountsToPayments < ActiveRecord::Migration[4.2]
  def change
    rename_table :accounts, :payments
  end
end
