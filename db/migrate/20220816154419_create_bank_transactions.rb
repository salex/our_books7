class CreateBankTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :bank_transactions do |t|
      t.references :book, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.references :entry, null: false, foreign_key: true
      t.date :post_date
      t.integer :amount
      t.string :fit_id
      t.string :ck_numb
      t.string :name
      t.string :memo

      t.timestamps
    end
    add_index :bank_transactions, :fit_id
  end
end
