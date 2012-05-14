class CreatePermissionUsers < ActiveRecord::Migration
  def up
    create_table :permission_users do |t|
      t.integer     :user_id
      t.integer     :permission_id
    end

    add_index :permission_users, :user_id
    add_index :permission_users, :permission_id
  end

  def down
    drop_table :permission_users
  end
end