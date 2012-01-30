require 'helper'

class ControllerTest < ActiveSupport::TestCase
  include Auth
  
  context "A controller" do
    setup do
      @user = Factory(:user)
      @controller = MockController.new
    end
    
    should "be logged out by default" do
      assert_equal false, @controller.send(:logged_in?)
    end
    
    should "have logged_in? and current_user methods" do      
      session = Session.create(@user)
      session.save    
      
      assert_equal @user, @controller.send(:current_user)
      assert_equal true, @controller.send(:logged_in?)
    end
  end
end