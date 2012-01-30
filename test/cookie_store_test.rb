require 'helper'

class CookieStoreTest < ActiveSupport::TestCase
  include Auth
  
  context "The CookieStore class" do
    setup do
      @user = Factory(:user)
      @request = MockRequest.new
    end
    
    should "save session in a request cookie store" do
      assert_equal [], @request.cookies.keys
      
      session = Session.new(@request)
      session.store = CookieStore.new(session)
      session.user = @user
      session.save
            
      assert_equal %w( auth-s auth-v ), @request.cookies.keys.sort
      assert_equal "#{@user.persistence_token}:#{@user.id}", @request.cookies['auth-s'][:value]
      assert_equal "test.dev", @request.cookies['auth-s'][:domain]
      
      assert_equal Encrypter.md5("#{@user.persistence_token}:#{@user.id}", @request.user_agent, @request.remote_ip), @request.cookies['auth-v'][:value]
      assert_equal "test.dev", @request.cookies['auth-v'][:domain]
    end
    
    should "read session data from cookies" do
      @request.cookies['auth-s'] = "#{@user.persistence_token}:#{@user.id}"      
      @request.cookies['auth-v'] = Encrypter.md5("#{@user.persistence_token}:#{@user.id}", @request.user_agent, @request.remote_ip)      
      
      session = Session.new(@request)
      session.store = CookieStore.new(session)
      session.read
      
      assert_equal true, session.valid?
      assert_equal @user, session.user
    end
    
    should "delete sessions from cookies" do
      session = Session.new(@request)
      session.store = CookieStore.new(session)
      session.user = @user
      
      session.save
      
      assert_equal true, session.valid?
      assert_equal @user, session.user
      assert_equal %w( auth-s auth-v ), @request.cookies.keys.sort
      
      session.destroy
      
      assert_equal false, session.valid?
      assert_equal nil, session.user
      assert_equal [], @request.cookies.keys.sort
    end 
  end
end