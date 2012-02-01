require 'helper'

class ControllerTest < ActiveSupport::TestCase
  include Challah
  
  context "A controller" do
    setup do
      @user = Factory(:user)
      @controller = MockController.new
    end
    
    should "be logged out by default" do
      assert_equal false, @controller.send(:current_user?)
    end
    
    should "have logged_in? and current_user methods" do      
      session = Session.create(@user)
      session.save    
      
      assert_equal true, @controller.send(:current_user?)
      assert_equal @user, @controller.send(:current_user)
    end
    
    should "redirect to login page if user is not logged in" do
      @controller.request.url = 'http://example.com/protected-page'
      @controller.stubs(:logged_in?).returns(false)
      @controller.expects(:redirect_to)
      @controller.send(:login_required)
      
      assert_equal @controller.session[:return_to], 'http://example.com/protected-page'
    end 
  end
end