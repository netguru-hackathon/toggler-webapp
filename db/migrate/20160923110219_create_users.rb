class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :slack_user_id
      t.string :toggl_api_token

      t.timestamps
    end
  end
end
