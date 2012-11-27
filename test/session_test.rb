require 'helper'

class SessionTest < ActiveSupport::TestCase
  include Challah

  context "An Challah::Session class" do
    should "have an inspected view" do
      user = create(:user)
      session = Session.create(user)

      assert /#<Session/ =~ session.inspect
    end

    should "use the test storage method" do
      assert_equal TestSessionStore, Challah.options[:storage_class]
    end

    should "create a new session instance from a user or id" do
      user = create(:user)

      assert_equal true, user.active?

      session = Session.create(user)
      assert_equal true, session.valid?
      assert_equal user.id, session.user_id
    end

    should "create a blank but invalid session for a non-existant or inactive user" do
      session = Session.create(999)
      assert_equal false, session.valid?
      assert_equal nil, session.user_id
    end

    should "persist a session" do
      user = create(:user)

      session = Session.create(user)
      assert_equal true, session.valid?
      assert_equal user, session.user

      session.save

      session_two = Session.find
      assert_equal true, session_two.valid?
      assert_equal user, session_two.user

      Session.destroy

      session_three = Session.find
      assert_equal false, session_three.valid?
      assert_equal nil, session_three.user
    end
  end

  context "A Challah::Session instance" do
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
      user = build(:user, :username => 'test-user')
      user.password!('abc123')
      user.save

      ::User.stubs(:find_for_session).returns(user)

      session = Session.new
      session.ip = '127.0.0.1'
      session.username = 'test-user'
      session.password = 'abc123'

      assert_difference 'user.session_count', 1 do
        assert_equal true, session.valid?
      end

      assert_equal user, session.user
      assert_equal user.id, session.user_id
      assert_equal true, session.persist?
      assert_equal true, session.save

      ::User.unstub(:find_for_session)
    end

    should "validate with an api key" do
      Challah.options[:api_key_enabled] = true

      user = create(:user, :api_key => '123456abcdefg')

      ::User.stubs(:find_for_session).returns(user)

      session = Session.new
      session.ip = '127.0.0.1'
      session.key = '123456abcdefg'

      assert_no_difference 'user.session_count' do
        assert_equal true, session.valid?
      end

      assert_equal user, session.user
      assert_equal user.id, session.user_id
      assert_equal false, session.persist?
      assert_equal false, session.save

      ::User.unstub(:find_for_session)

      Challah.options[:api_key_enabled] = false
    end

    should "reject if password is incorrect" do
      user = build(:user, :username => 'test-user')
      user.password!('abc123')
      user.save

      ::User.stubs(:find_for_session).returns(user)

      session = Session.new
      session.username = 'test-user'
      session.password = 'bad-pass'

      user.expects(:failed_authentication!).once

      assert_equal false, session.valid?
      assert_equal nil, session.user

      ::User.unstub(:find_for_session)
    end
  end
end