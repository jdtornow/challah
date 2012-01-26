class SetupAuth < ActiveRecord::Migration
  def up
    # Users
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :email
      t.string :crypted_password
      t.string :persistence_token
      t.string :api_key
      t.integer :role_id
      t.datetime :last_login_at
      t.integer :login_count, :default => 0
      t.integer :failed_login_count, :default => 0
      t.string :last_login_ip
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
    
    # Permissions
    create_table :permissions do |t|
      t.string :name
      t.text :description
      t.string :key, :limit => 50
      t.boolean :locked, :default => false
    end
    
    add_index :permissions, :key
    
    # Permissions/Roles    
    create_table :permission_roles do |t|
      t.integer :role_id
      t.integer :permission_id
    end
    
    add_index :permission_roles, :role_id
    add_index :permission_roles, :permission_id
    
    # Permissions/Users
    create_table :permission_users do |t|
      t.integer :user_id
      t.integer :permission_id
    end
    
    add_index :permission_users, :user_id
    add_index :permission_users, :permission_id
    
    # Roles
    create_table :roles do |t|
      t.string :name
      t.text :description
      t.string :default_path, :default => '/'
      t.boolean :locked, :default => false
    end
  end

  def down
    # Users
    drop_table :users
    
    # Permissions
    drop_table :permissions
    
    # Permissions/Roles
    drop_table :permission_roles
    
    # Permissions/Users
    drop_table :permission_users
    
    # Roles
    drop_table :roles
  end
end