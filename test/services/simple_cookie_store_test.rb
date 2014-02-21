require 'test_helper'

class SimpleCookieStoreTest < ActiveSupport::TestCase
  include Challah

  class FakeUserModel

    def self.table_name
      'fake_user_peoples'
    end

  end

  context "The SimpleCookieStore class" do
    setup do
      @user = create(:user)
      @request = MockRequest.new
    end

    should "save session in a request cookie store" do
      assert_equal [], @request.cookies.keys

      session = Session.new(@request)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = @user
      session.save

      assert_equal %w( challah-s challah-v ), @request.cookies.keys.sort
      assert_equal "#{@user.persistence_token}@#{@user.id}", @request.cookies['challah-s'][:value]
      assert_equal "test.dev", @request.cookies['challah-s'][:domain]

      assert_equal Encrypter.md5("#{@user.persistence_token}@#{@user.id}"), @request.cookies['challah-v'][:value]
      assert_equal "test.dev", @request.cookies['challah-v'][:domain]
    end

    should "save session in a namespaced cookie store for non user tables" do
      assert_equal [], @request.cookies.keys

      session = Session.new(@request, {}, FakeUserModel)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = @user
      session.save

      assert_equal %w( challah-d635fd-s challah-d635fd-v ), @request.cookies.keys.sort
      assert_equal "#{@user.persistence_token}@#{@user.id}", @request.cookies['challah-d635fd-s'][:value]
      assert_equal "test.dev", @request.cookies['challah-d635fd-s'][:domain]

      assert_equal Encrypter.md5("#{@user.persistence_token}@#{@user.id}"), @request.cookies['challah-d635fd-v'][:value]
      assert_equal "test.dev", @request.cookies['challah-d635fd-v'][:domain]
    end

    should "be able to inspect the store" do
      session = Session.new(@request)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = @user
      session.save

      assert session.store.inspect =~ /<SimpleCookieStore:(.*?)>/, 'Does not match'
    end

    should "read cookies and detect tampered verification cookies" do
      assert_equal [], @request.cookies.keys

      session = Session.new(@request)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = @user
      session.save

      validation_cookie_val = Encrypter.md5("#{@user.persistence_token}@#{@user.id}")
      session_cookie_val = "#{@user.persistence_token}@#{@user.id}"

      assert_equal session_cookie_val, @request.cookies['challah-s'][:value]
      assert_equal session_cookie_val, session.store.send(:session_cookie)[:value]
      assert_equal validation_cookie_val, @request.cookies['challah-v'][:value]
      assert_equal validation_cookie_val, session.store.send(:validation_cookie)[:value]

      session.store.stubs(:validation_cookie).returns(validation_cookie_val)
      session.store.stubs(:session_cookie).returns(session_cookie_val)

      session2 = Session.new(@request)
      session2.persist = true
      session2.store = session.store
      session2.read

      assert_equal true, session2.store.send(:existing?)
      assert_equal true, session2.valid?
      assert_equal @user.id, session2.user_id

      session.store.stubs(:validation_cookie).returns('bad-value')

      session3 = Session.new(@request)
      session3.store = session.store
      session3.read

      assert_equal false, session3.store.send(:existing?)
      assert_equal false, session3.valid?
    end

    should "delete sessions from cookies" do
      session = Session.new(@request)
      session.store = SimpleCookieStore.new(session)
      session.user = @user
      session.persist = true

      session.save

      assert_equal true, session.valid?
      assert_equal @user, session.user
      assert_equal %w( challah-s challah-v ), @request.cookies.keys.sort

      session.destroy

      assert_equal false, session.valid?
      assert_equal nil, session.user
      assert_equal [], @request.cookies.keys.sort
    end
  end
end
