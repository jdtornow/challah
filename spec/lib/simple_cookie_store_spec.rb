require 'spec_helper'

module Challah
  # TODO make these specs not look like unit tests
  describe SimpleCookieStore do

    class FakeUserModel
      def self.table_name
        'fake_user_peoples'
      end
    end

    let(:user) { create(:user) }
    let(:request) { MockRequest.new }

    it "should save session in a request cookie store" do
      assert_equal [], request.cookies.keys

      session = Session.new(request)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = user
      session.save

      assert_equal %w( challah-s challah-v ), request.cookies.keys.sort
      assert_equal "#{user.persistence_token}@#{user.to_global_id}", request.cookies['challah-s'][:value]
      assert_equal "test.dev", request.cookies['challah-s'][:domain]

      assert_equal Encrypter.md5("#{user.persistence_token}@#{user.to_global_id}"), request.cookies['challah-v'][:value]
      assert_equal "test.dev", request.cookies['challah-v'][:domain]
    end

    it "should save session in a namespaced cookie store for non user tables" do
      assert_equal [], request.cookies.keys

      session = Session.new(request, {}, FakeUserModel)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = user
      session.save

      assert_equal %w( challah-d635fd-s challah-d635fd-v ), request.cookies.keys.sort
      assert_equal "#{user.persistence_token}@#{user.to_global_id}", request.cookies['challah-d635fd-s'][:value]
      assert_equal "test.dev", request.cookies['challah-d635fd-s'][:domain]

      assert_equal Encrypter.md5("#{user.persistence_token}@#{user.to_global_id}"), request.cookies['challah-d635fd-v'][:value]
      assert_equal "test.dev", request.cookies['challah-d635fd-v'][:domain]
    end

    it "should be able to inspect the store" do
      session = Session.new(request)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = user
      session.save

      assert session.store.inspect =~ /<SimpleCookieStore:(.*?)>/, 'Does not match'
    end

    it "should read cookies and detect tampered verification cookies" do
      assert_equal [], request.cookies.keys

      session = Session.new(request)
      session.store = SimpleCookieStore.new(session)
      session.persist = true
      session.user = user
      session.save

      validation_cookie_val = Encrypter.md5("#{user.persistence_token}@#{user.to_global_id}")
      session_cookie_val = "#{user.persistence_token}@#{user.to_global_id}"

      assert_equal session_cookie_val, request.cookies['challah-s'][:value]
      assert_equal session_cookie_val, session.store.send(:session_cookie)[:value]
      assert_equal validation_cookie_val, request.cookies['challah-v'][:value]
      assert_equal validation_cookie_val, session.store.send(:validation_cookie)[:value]

      allow(session.store).to receive(:validation_cookie).and_return(validation_cookie_val)
      allow(session.store).to receive(:session_cookie).and_return(session_cookie_val)

      session2 = Session.new(request)
      session2.persist = true
      session2.store = session.store
      session2.read

      assert_equal true, session2.store.send(:existing?)
      assert_equal true, session2.valid?
      assert_equal user.to_global_id, session2.user_id

      allow(session.store).to receive(:validation_cookie).and_return('bad-value')

      session3 = Session.new(request)
      session3.store = session.store
      session3.read

      assert_equal false, session3.store.send(:existing?)
      assert_equal false, session3.valid?
    end

    it "should delete sessions from cookies" do
      session = Session.new(request)
      session.store = SimpleCookieStore.new(session)
      session.user = user
      session.persist = true

      session.save

      assert_equal true, session.valid?
      assert_equal user, session.user
      assert_equal %w( challah-s challah-v ), request.cookies.keys.sort

      session.destroy

      expect(session.valid?).to eq(false)
      expect(session.user).to be_nil
      expect(request.cookies.keys.sort).to eq([])
    end
  end
end
