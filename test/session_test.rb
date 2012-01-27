require 'helper'

class SessionTest < ActiveSupport::TestCase
  include Auth
  
  class MockController    
  end
  
  class MockRequest
  end
  
  context "A Auth::Session instance" do    
    should "receive a request and params object" do
      session = Session.new(MockRequest.new, { :username => 'test-user', :password => 'test123' })
      
      assert_not_nil session.request
      assert_not_nil session.params
      
      assert_equal true, session.username?
      assert_equal true, session.password?
    end
    
    should "be able to set a username/password" do
      session = Session.new
      
      assert_equal false, session.username?
      assert_equal false, session.password?
      
      session.username = 'test-user'
      session.password = 'abc123'
      
      assert_equal true, session.username?
      assert_equal true, session.password?
      
      assert_equal 'test-user', session.username
      assert_equal nil, session.password
    end
    
    should "validate with a password" do
      user = Factory(:user, :username => 'test-user')
      
      User.stubs(:find_for_session).returns(user)
      
      session = Session.new
      session.username = 'test-user'
      session.password = 'abc123'
      session.ip = '127.0.0.1'
      
      user.expects(:successful_authentication!).with('127.0.0.1').once
      
      assert_equal true, session.valid?
      assert_equal user, session.user
      
      User.unstub(:find_for_session)
    end
    
    should "reject if password is incorrect" do
      user = Factory(:user, :username => 'test-user')
      
      User.stubs(:find_for_session).returns(user)
      
      session = Session.new
      session.username = 'test-user'
      session.password = 'bad-pass'
      
      user.expects(:failed_authentication!).once
                  
      assert_equal false, session.valid?      
      assert_equal nil, session.user
      
      User.unstub(:find_for_session)
    end    
  end
end