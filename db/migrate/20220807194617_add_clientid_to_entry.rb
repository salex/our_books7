class AddClientidToEntry < ActiveRecord::Migration[7.0]
  def change
    add_column :entries, :client_id, :bigint
    add_column :splits, :client_id,  :bigint

  end
end
