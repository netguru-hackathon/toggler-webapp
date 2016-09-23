class AddDefaultsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :default_workspace_name, :string
    add_column :users, :default_project_name, :string
    add_column :users, :default_billable, :boolean

    add_index :users, :slack_user_id, unique: true
  end
end
