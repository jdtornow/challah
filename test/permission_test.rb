require 'helper'

class PermissionTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :key
  
  should have_many :roles
  should have_many :users
  should have_many :permission_roles
  should have_many :permission_users
  
  context "With existing permissions" do
    setup do
      Factory(:permission)
    end
    
    should validate_uniqueness_of :name
    should validate_uniqueness_of :key
  end
  
  context "The Permission class" do
    should "load with the brackets shortcut" do
      one = Factory(:permission, :name => 'Permission One', :key => 'permission_one')
      two = Factory(:permission, :name => 'Permission Two', :key => 'permission_two')

      assert_equal one, Permission[:permission_one]
      assert_equal one, Permission[:Permission_One]
      assert_equal two, Permission['Permission Two']
      assert_equal two, Permission[' permission two  ']
      assert_equal nil, Permission[:no_permission_exists]
    end
  end
  
  context "A Permission instance" do    
    should "get added to the admin role on create" do
      admin_role = Factory(:role, :name => 'Administrator')
      assert_equal nil, admin_role.permission_keys.index('new_permission')
      
      #Role.stubs(:admin).returns(admin_role)
      
      permission = Permission.new(:name => 'New Permission', :key => 'new_permission', :description => 'This is just a test.')
      
      assert_difference [ 'Permission.count', 'PermissionRole.count' ], 1 do
        assert permission.save
      end      
    end
  end
end