require 'helper'

class RoleTest < ActiveSupport::TestCase
  should validate_presence_of :name  
  should have_many :users

  should have_many :permission_roles
  should have_many :permissions
  
  context "The Role model" do
    should "be able to load a role with Role[:role_name] shortcut" do
      test = Factory(:role, :name => 'Test Role')
      default = Factory(:default_role)

      assert_equal test, Role[:test_role]
      assert_equal default, Role[:default]
      assert_equal default, Role['Default']
      assert_equal default, Role[' defAult  ']
      assert_equal nil, Role[:bad_role]
    end
  end
  
  context "A Role instance" do
    should "have a permission keys array" do
      admin_permission = Factory(:admin_permission)
      users_permission = Factory(:users_permission)
      
      role = Factory.build(:role)      
      
      assert_equal 0, role.permission_keys.length
      
      assert_difference 'Role.count', 1 do
        role.save
      end
      
      assert_difference 'PermissionRole.count', 2 do
        role.permission_keys = %w( admin manage_users )
        role.save
      end
      
      assert_equal %w( admin manage_users ), role.permission_keys.sort
    end
    
    should "be able to check for a permission" do
      role = Role.new
      role.stubs(:permission_keys).returns(%w( admin permission1 permission 2 ))
      
      assert_equal true, role.permission?(:admin)
      assert_equal true, role.has(:admin)
      assert_equal true, role.admin?
      
      assert_equal true, role.permission?(:permission1)
      assert_equal true, role.has(:permission1)
      assert_equal true, role.permission1?
      
      assert_equal false, role.permission?(:bad)
      assert_equal false, role.has(:bad)
      assert_equal false, role.bad?
      
      # no question mark, use regular method_missing
      
      assert_raises NoMethodError do
        role.bad_call_without_question_mark
      end
    end
  end
end