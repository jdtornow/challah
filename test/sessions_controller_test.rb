require 'helper'

class SessionsControllerTest < ActionController::TestCase
  tests Auth::SessionsController
  
  context "The sessions controller" do
    setup do
      @user = Factory(:user, :username => 'sessions-user-test')
    end
    
    should "have a sign-in page" do
      get :new
      assert_response :success
    end
    
    should "be able to sign in" do
      Auth::Session.any_instance.stubs(:save).returns(true)
      
      post :create, :username => 'sessions-user-test', :password => 'abc123'
      assert_redirected_to '/'
      
      Auth::Session.any_instance.unstub(:save)
    end
    
    should "send you back to the sign in page if you can't sign in" do
      Auth::Session.any_instance.stubs(:save).returns(false)
      
      post :create, :username => 'sessions-user-test', :password => 'abc123'
      assert_redirected_to '/sign-in'
      
      Auth::Session.any_instance.unstub(:save)
    end 
    
    should "be able to sign out" do
      get :destroy
      
      assert_redirected_to '/sign-in'
    end 
  end
end