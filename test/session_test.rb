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
    end
    
    should "be able to set a username" do
      session = Session.new
      
      assert_equal false, session.username?
      
      session.username = 'test-user'
      
      assert_equal true, session.username?
      
      assert_equal 'test-user', session.username
    end
    
    should "be able to set attributes" do
      session = Session.new
      
      assert_equal Hash.new, session.params
            
      session.username = 'test-user'
      expected = { :username => 'test-user' }
      assert_equal expected, session.params
      assert_equal true, session.username?
      
      session.password = 'abc123'
      expected = { :username => 'test-user', :password => 'abc123' }
      assert_equal expected, session.params
      assert_equal true, session.password?
      
      session.api_key = '122345873847'
      expected = { :username => 'test-user', :password => 'abc123', :api_key => '122345873847' }
      assert_equal expected, session.params
      assert_equal true, session.api_key?
      
      session.other = true
      expected = { :username => 'test-user', :password => 'abc123', :api_key => '122345873847', :other => true }
      assert_equal expected, session.params
      assert_equal true, session.other?
      
      assert_raises NoMethodError do
        session.no_key
      end
    end    
    
    should "validate with a password" do
      user = Factory(:user, :username => 'test-user')
      
      User.stubs(:find_for_session).returns(user)
      
      session = Session.new
      session.ip = '127.0.0.1'
      session.username = 'test-user'
      session.password = 'abc123'
      
      user.expects(:successful_authentication!).with('127.0.0.1').once
      
      assert_equal true, session.valid?
      assert_equal user, session.user
      
      User.unstub(:find_for_session)
    end
    
    should "validate with an api key" do
      user = Factory(:user, :api_key => '123456abcdefg')
      
      User.stubs(:find_for_session).returns(user)
      
      session = Session.new
      session.ip = '127.0.0.1'
      session.api_key = '123456abcdefg'
      
      assert_equal true, session.valid?
      assert_equal user, session.user
      
      user.expects(:successful_authentication!).with('127.0.0.1').once
      
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