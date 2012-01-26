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
      Factory(:user)
    end
    
    should validate_uniqueness_of :email
    should validate_uniqueness_of :username
  end
  
  context "A user instance" do
    setup do
      @user = User.new
    end
    
    should "have a name attribute that returns the full name" do
      @user.stubs(:first_name).returns('Cal')
      @user.stubs(:last_name).returns('Ripken')

      assert_equal "Cal Ripken", @user.name
      assert_equal "Cal R.", @user.small_name
    end
  end
end