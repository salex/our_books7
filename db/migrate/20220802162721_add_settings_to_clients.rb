class AddSettingsToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :setting, :text
  end
end
