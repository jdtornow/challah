class ChallahCreateUsers < ActiveRecord::Migration<%= migration_version %>
  def change
     create_table :users do |t|
      t.string      :first_name
      t.string      :last_name
      t.string      :email
      t.string      :email_hash
      t.string      :persistence_token
      t.string      :api_key
      t.datetime    :last_session_at
      t.integer     :session_count, default: 0
      t.integer     :failed_auth_count, default: 0
      t.bigint      :created_by, default: 0
      t.bigint      :updated_by, default: 0
      t.integer     :status, default: 0 # defaults to :active
      t.timestamps  null: true
    end

    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :email
    add_index :users, :api_key

    create_table :authorizations do |t|
      t.references  :user
      t.string      :provider, limit: 50
      t.string      :uid
      t.string      :token, limit: 500
      t.datetime    :expires_at
      t.datetime    :last_session_at
      t.integer     :session_count, default: 0
      t.timestamps  null: true
    end

    add_index :authorizations, [ :user_id, :provider ]
    add_index :authorizations, :uid
    add_index :authorizations, :token
  end
end
