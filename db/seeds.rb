# Add default admin permission and role and normal user with no permissions
if Permission.count.zero? and Role.count.zero?
  # Create the admin permission.
  admin_permission = Permission.create!({
    :name => 'Administrator',
    :key => 'admin',
    :description => 'Administrative users have unrestricted access to all components within the application.',
    :locked => true
    }, :without_protection => true)

  # Create the manage users permission
  manage_users_permission = Permission.create!({
    :name => 'Manage Users',
    :key => 'manage_users',
    :description => 'Access to add, edit and remove application users.',
    :locked => true
    }, :without_protection => true)

  # Create the admin role
  admin_role = Role.create!({
    :name => 'Administrator',
    :description => 'Administrative users have unrestricted access to all components within the application.',
    :default_path => '/',
    :locked => true
    }, :without_protection => true)

  # Make sure admin role has the admin permission
  PermissionRole.create!({
    :role_id => admin_role.id,
    :permission_id => admin_permission.id
    }, :without_protection => true)


  # Make sure the admin role has the manage_users permission
  PermissionRole.create!({
    :role_id => admin_role.id,
    :permission_id => manage_users_permission.id
    }, :without_protection => true)

  # Set up the default user role, this role has no permissions.
  Role.create!({
    :name => 'Default',
    :description => 'Default users can log in to the application.',
    :default_path => '/'
    }, :without_protection => true)
end