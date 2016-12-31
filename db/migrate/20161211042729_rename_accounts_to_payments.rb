class RenameAccountsToPayments < ActiveRecord::Migration
  def change
    rename_table :accounts, :payments
  end
end
