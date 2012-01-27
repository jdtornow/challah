class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :email
      t.string :crypted_password
      t.string :persistence_token
      t.string :api_key
      t.integer :role_id
      t.datetime :last_session_at
      t.string :last_session_ip
      t.integer :session_count, :default => 0
      t.integer :failed_auth_count, :default => 0      
      t.integer :created_by, :default => 0
      t.integer :updated_by, :default => 0
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean :active, :default => true
      t.timestamps :null => true
    end
    
    add_index :users, :username
    add_index :users, :first_name
    add_index :users, :last_name
    add_index :users, :email
    add_index :users, :api_key
    add_index :users, :role_id
  end

  def down
    drop_table :users
  end
end