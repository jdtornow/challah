require 'helper'

class UserTest < ActiveSupport::TestCase
  should validate_presence_of :email
  should validate_presence_of :first_name
  should validate_presence_of :last_name
  should validate_presence_of :role_id
  should validate_presence_of :username

  should belong_to :role

  should have_many :permission_users
  should have_many :permissions

  context "With an existing user" do
    setup do
      create(:normal_user)
    end

    should validate_uniqueness_of :email
    should validate_uniqueness_of :username
  end

  context "A User class" do
    should "find a user by username or email" do
      user_one = create(:normal_user, :username => 'test-user', :email => 'tester@example.com')
      user_two = create(:normal_user, :username => 'test-user-2', :email => 'tester2@example.com')

      assert_equal user_one, User.find_for_session('test-user')
      assert_equal user_one, User.find_for_session('tester@example.com')

      assert_equal user_two, User.find_for_session('test-user-2')
      assert_equal user_two, User.find_for_session('tester2@example.com')

      assert_equal nil, User.find_for_session(' ')
      assert_equal nil, User.find_for_session('not-existing')
    end

    should "have protected attributes" do
      assert Array === User.protected_attributes

      assert_difference 'User.protected_attributes.size', 1 do
        User.protect_attributes(:blah)
      end
    end

    should "be able to find users by role" do
      admin_role = create(:administrator_role)
      another_role = create(:role, :name => 'Another')

      create_list(:user, 5, :role_id => admin_role.id)
      create_list(:user, 2, :role_id => another_role.id)

      assert_equal 7, User.count

      assert_equal 5, User.find_all_by_role(:administrator).count
      assert_equal 5, User.find_by_role(:administrator).count
      assert_equal 5, User.find_all_by_role(admin_role.id).count
      assert_equal 2, User.find_all_by_role(another_role).count
    end

    should "be able to find users by a permission" do
      # Set up admin role first so it gets all subsequent permissions
      admin_role = create(:administrator_role)

      # Create a fake permission for checking
      permission = create(:permission, :name => 'Test Permission', :key => 'test')

      # Create a new fake role to house the new permission
      role = build(:role, :name => 'Test Role')
      role.permission_keys = %w( test )
      role.save

      # Create another fake role that doesn't have permissions
      other_role = create(:role, :name => 'Another Role')

      # Add a few users in each of these roles
      create_list(:user, 3, :role_id => role.id)
      create_list(:user, 2, :role_id => admin_role.id)
      create_list(:user, 4, :role_id => other_role.id)

      # Make sure the roles are assigned to the permission
      assert_equal [ admin_role, role ].sort, permission.roles.sort

      # Make sure the users are assigned to the right roles
      assert_equal 3, role.users.count
      assert_equal 2, admin_role.users.count
      assert_equal 4, other_role.users.count

      # Create a few fake users that are not in these roles and manually
      # assign the permission to them
      user1 = build(:user, :role_id => other_role.id)
      user1.permission_keys = %w( test manage_users )
      user1.save

      user2 = build(:user, :role_id => other_role.id)
      user2.permission_keys = %w( test )
      user2.save

      # Check to make sure the users have the right keys
      assert_equal %w( manage_users test ), user1.permission_keys.sort
      assert_equal %w( test ), user2.permission_keys

      # Now we should be able to find users by a specific permission key
      assert_equal 7, User.find_all_by_permission(:test).count
      assert_equal 7, User.find_all_by_permission(Permission[:test]).count
      assert_equal 7, User.find_all_by_permission(permission).count
      assert_equal 7, User.find_all_by_permission(permission.id).count

      assert_equal 0, User.find_by_permission(nil).count

      assert_equal 2, User.find_all_by_permission(:admin).count
      assert_equal 3, User.find_by_permission(:manage_users).count
    end
  end

  context "A user instance" do
    should "have a name attribute that returns the full name" do
      user = User.new

      user.stubs(:first_name).returns('Cal')
      user.stubs(:last_name).returns('Ripken')

      assert_equal "Cal Ripken", user.name
      assert_equal "Cal R.", user.small_name
    end

    should "have a default_path where this user will be sent upon login" do
      role = Role.new
      role.stubs(:default_path).returns('/role-path')

      user = User.new

      user.stubs(:role).returns(role)
      assert_equal '/role-path', user.default_path

      user.stubs(:role).returns(nil)
      assert_equal '/', user.default_path
    end

    should "have an active? user flag" do
      user = User.new

      user.active = true
      assert_equal true, user.active
      assert_equal true, user.active?
      assert_equal true, user.valid_session?

      user.active = false
      assert_equal false, user.active
      assert_equal false, user.active?
      assert_equal false, user.valid_session?
    end

    should "not allow updating of certain protected attributes" do
      user = create(:user, :first_name => 'Old', :last_name => 'Nombre')

      assert_equal false, user.new_record?

      assert_equal 0, user.created_by
      assert_equal 1, user.role_id
      assert_equal 'Old Nombre', user.name

      user.update_account_attributes({
        :created_by => 1,
        :first_name => 'New',
        :last_name => 'Name',
        :role_id => 5
      })

      assert_equal 0, user.created_by
      assert_equal 1, user.role_id
      assert_equal 'New Name', user.name
    end

    should "create a user with password and authenticate them" do
      user = build(:user)

      user.password = 'abc123'
      user.password_confirmation = 'abc123'
      assert_equal 'abc123', user.password

      assert user.save

      assert_equal true, user.authenticate('abc123')
      assert_equal true, user.authenticate(:password, 'abc123')
      assert_equal false, user.authenticate('test123')
    end

    should "be able to update a user without changing their password" do
      user = create(:user)

      assert_equal true, user.authenticate('abc123')

      assert user.update_attributes(:first_name => 'New', :password => '', :password_confirmation => '')

      assert_equal 'New', user.first_name
      assert_equal true, user.authenticate('abc123')
    end

    should "validate a password" do
      user = build(:user)
      assert_equal true, user.valid?

      user.password = ''
      user.password_confirmation = ''
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password can't be blank")

      user.password = 'abc'
      user.password_confirmation = 'abc'
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password is not a valid password. Please enter at least 4 letters or numbers.")

      user.password = 'abc456'
      user.password_confirmation = 'abc123'
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password does not match the confirmation password.")
    end

    should "get and set permission keys" do
      %w( run pass throw block ).each { |p| create(:permission, :key => p) }

      user = build(:user)

      user.stubs(:role).returns(Role.new)
      user.role.stubs(:permission_keys).returns([])

      user.save

      assert_equal [], user.permission_keys

      user.permission_keys = %w( pass throw run )

      assert_difference 'PermissionUser.count', 3 do
        user.save
      end

      assert_equal true, user.pass?
      assert_equal true, user.has(:pass)
      assert_equal true, user.permission?(:pass)

      assert_equal true, user.run?
      assert_equal true, user.has(:run)
      assert_equal true, user.permission?(:run)

      assert_equal false, user.fake?
      assert_equal false, user.has(:fake)
      assert_equal false, user.permission?(:fake)

      assert_raises NoMethodError do
        user.does_not_exist
      end
    end

    should "authenticate through various means by default" do
      user = create(:user)

      # By password
      assert_equal false, user.authenticate_with_password('test123')
      assert_equal false, user.authenticate(:password, 'test123')
      assert_equal false, user.authenticate('test123')

      assert_equal true, user.authenticate_with_password('abc123')
      assert_equal true, user.authenticate(:password, 'abc123')
      assert_equal true, user.authenticate('abc123')

      # By api key
      user.stubs(:api_key).returns('this-is-my-api-key')

      assert_equal true, user.authenticate_with_api_key('this-is-my-api-key')
      assert_equal true, user.authenticate_with_api_key('this-is-my-api-key')

      assert_equal false, user.authenticate_with_api_key('this-is-not-my-api-key')
      assert_equal false, user.authenticate_with_api_key('this-is-not-my-api-key')

      # With an unknown authentication method
      assert_equal false, user.authenticate(:blah, 'sdsd', 'sdlsk')
    end

    should "have successful and failed authentication methods" do
      user = create(:user)

      assert_nil user.last_session_ip
      assert_nil user.last_session_at

      assert_difference 'user.session_count', 1 do
        user.successful_authentication!('192.168.0.1')
      end

      assert_not_nil user.last_session_ip
      assert_not_nil user.last_session_at

      assert_difference 'user.failed_auth_count', 1 do
        user.failed_authentication!
      end
    end
  end
end