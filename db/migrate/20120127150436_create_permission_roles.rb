class CreatePermissionRoles < ActiveRecord::Migration
  def up
    create_table :permission_roles do |t|
      t.integer     :role_id
      t.integer     :permission_id
    end

    add_index :permission_roles, :role_id
    add_index :permission_roles, :permission_id
  end

  def down
    drop_table :permission_roles
  end
end