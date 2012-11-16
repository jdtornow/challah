class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.integer     :user_id
      t.string      :provider, limit: 50
      t.string      :uid
      t.string      :token, limit: 500
      t.datetime    :last_session_at
      t.string      :last_session_ip
      t.integer     :session_count, default: 0
      t.timestamps
    end

    add_index :authorizations, :user_id
    add_index :authorizations, [ :user_id, :provider ]
    add_index :authorizations, :uid
    add_index :authorizations, :token
  end
end