require 'helper'

class RoleTest < ActiveSupport::TestCase
  should validate_presence_of :name  
  should have_many :users

  should have_many :permission_roles
  should have_many :permissions
  
  context "The Role model" do
    should "be able to load a role with Role[:role_name] shortcut" do
      assert_equal 0, Role.count
      
      test = Factory(:role, :name => 'Test Role')
      default = Factory(:default_role)

      assert_equal test, Role[:test_role]
      assert_equal default, Role[:default]
      assert_equal default, Role["Default"]
      assert_equal default, Role["  default"]
      assert_equal nil, Role[:bad_role]
    end
  end
end