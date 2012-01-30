# Add default admin permission and role and normal user with no permissions
if Permission.count.zero? and Role.count.zero?
  admin_permission = Permission.create!(:name => 'Administrator', :key => 'admin', :description => 'Administrative users have unrestricted access to all components within the application.', :locked => true)
  manage_users_permission = Permission.create!(:name => 'Manage Users', :key => 'manage_users', :description => 'Access to add, edit and remove application users.', :locked => true)
  
  admin_role = Role.create!(:name => 'Administrator', :description => 'Administrative users have unrestricted access to all components within the application.', :default_path => '/', :locked => true)
  
  PermissionRole.create!(:role_id => admin_role.id, :permission_id => admin_permission.id)
  PermissionRole.create!(:role_id => admin_role.id, :permission_id => manage_users_permission.id)
  
  normal_role = Role.create!(:name => 'Default', :description => 'Default users can log in to the application.', :default_path => '/')
end

if User.count.zero?
  User.create! :role_id => Role.admin.id,
                  :first_name => 'Admin',
                  :last_name => 'User',
                  :username => 'admin',
                  :email => 'admin@example.com',
                  :password => 'abc123',
                  :password_confirmation => 'abc123'
  
  
  puts "Added admin user (pw: abc123)"
end