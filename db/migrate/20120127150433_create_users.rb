class CreateUsers < ActiveRecord::Migration

  def change
    create_table :users do |t|
      t.string      :first_name
      t.string      :last_name
      t.string      :email
      t.string      :email_hash
      t.string      :persistence_token
      t.string      :api_key
      t.datetime    :last_session_at
      t.string      :last_session_ip
      t.integer     :session_count, default: 0
      t.integer     :failed_auth_count, default: 0
      t.integer     :created_by, default: 0
      t.integer     :updated_by, default: 0
      t.datetime    :created_at
      t.datetime    :updated_at
      t.integer     :status, default: 0 # defaults to :active
      t.timestamps  null: true
    end

    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :email
    add_index :users, :api_key
  end

end
