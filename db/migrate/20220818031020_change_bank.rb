class ChangeBank < ActiveRecord::Migration[7.0]
  def change
    change_column :bank_transactions, :entry_id, :bigint, null: true

  end
end
