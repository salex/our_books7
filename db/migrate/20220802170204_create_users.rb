class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.references :client, null: false, foreign_key: true
      t.string :email
      t.string :username
      t.string :full_name
      t.string :roles
      t.integer :default_book
      t.string :password_digest

      t.timestamps
    end
  end
end
