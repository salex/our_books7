class CreateStashes < ActiveRecord::Migration[7.0]
  def change
    create_table :stashes do |t|
      t.references :client, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.string :key
      t.date :date
      t.text :json
      t.text :yaml
      t.text :slim
      t.string :status

      t.timestamps
    end
    add_index :stashes, :key
  end
end
