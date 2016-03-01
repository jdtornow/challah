require "spec_helper"

module Challah
  # TODO make these specs not look like unit tests
  describe User do
    it "should normalize the user's email" do
      user = build(:user, email: "  YELLING@example.com  ")
      user.save
      expect(user.email).to eq "yelling@example.com"
    end

    it "should find a user by username or email" do
      user_one = build(:user, :username => ' Test-user ', :email => 'tester@example.com')
      user_two = build(:user, :username => 'test-user-2  ', :email => 'tester2@example.com')

      user_one.password!('test123')
      user_two.password!('test123')

      user_one.save
      user_two.save

      assert_equal user_one, User.find_for_session('test-user   ')
      assert_equal user_one, User.find_for_session('tester@example.com   ')

      assert_equal user_one, User.find_for_session('Test-user')
      assert_equal user_one, User.find_for_session('tester@example.com')

      assert_equal user_two, User.find_for_session('test-user-2')
      assert_equal user_two, User.find_for_session('tester2@example.com')

      assert_equal nil, User.find_for_session(' ')
      assert_equal nil, User.find_for_session('not-existing')
      assert_equal nil, User.find_for_session(nil)
    end

    it "should find by username or email regardless of case" do
      user = build(:user, :username => 'test-user', :email => 'tester@example.com')
      user.password!('test123')
      user.save

      assert_equal user, User.find_for_session('TEST-user')
      assert_equal user, User.find_for_session('TESTER@example.com')
    end

    it "should have a reference to the authorizations model" do
      assert_equal ::Authorization, User.authorization_model
      assert_equal 'authorizations', User.authorizations_table_name
    end

    it "should have a name attribute that returns the full name" do
      user = User.new

      allow(user).to receive(:first_name).and_return('Cal')
      allow(user).to receive(:last_name).and_return('Ripken')

      assert_equal "Cal Ripken", user.name
      assert_equal "Cal R.", user.small_name
    end

    it "should have an active? user flag" do
      user = User.new

      user.active = true
      assert_equal true, user.active
      assert_equal true, user.active?
      assert_equal true, user.valid_session?

      user.active = false
      assert_equal false, user.active
      assert_equal false, user.active?
      assert_equal false, user.valid_session?
    end

    it "should create a user with password and authenticate them" do
      user = build(:user)

      user.password = 'abc123'
      user.password_confirmation = 'abc123'
      assert_equal 'abc123', user.password

      assert user.save

      assert_equal true, user.provider?(:password)
      expect(user.provider(:password)).to_not be_nil

      assert_equal true, user.authenticate('abc123')
      assert_equal true, user.authenticate(:password, 'abc123')
      assert_equal false, user.authenticate('test123')
    end

    it "should be able to update a user without changing their password" do
      user = build(:user)
      user.password!('abc123')
      user.save

      assert_equal true, user.authenticate('abc123')

      user.first_name = 'New'
      user.password = ''
      user.password_confirmation = ''
      assert user.save

      assert_equal 'New', user.first_name
      assert_equal true, user.authenticate('abc123')
    end

    it "should validate a password" do
      user = build(:user)
      user.password!('abc123')
      assert_equal true, user.valid?

      user.username = 'user123'
      user.password = ''
      user.password_confirmation = ''
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password can't be blank")

      user.password = 'abc'
      user.password_confirmation = 'abc'
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password is not a valid password. Please enter at least 4 letters or numbers.")

      user.password = 'abc456'
      user.password_confirmation = 'abc123'
      assert_equal false, user.valid?
      assert user.errors.full_messages.include?("Password does not match the confirmation password.")
    end

    it "should create a password without confirmation when using !" do
      user = build(:user)
      user.password!('holla')
      assert_equal true, user.valid?
    end

    it "should reasonable validate an email address" do
      user = build(:user)

      user.email = 'john@challah.me'
      assert_equal true, user.valid?

      user.email = 'john@challah.m@me.e'
      assert_equal false, user.valid?
    end

    it "should always lower case a username when setting" do
      user = build(:user)
      user.username = 'JimBob'
      assert_equal 'jimbob', user.username
    end

    it "should not authenticate with a password if none is given" do
      user = create(:user)
      assert_equal false, user.authenticate_with_password('abc123')
    end

    it "should authenticate through various means by default" do
      user = build(:user)
      user.password!('abc123')
      user.save

      # By password
      assert_equal false, user.authenticate_with_password('test123')
      assert_equal false, user.authenticate(:password, 'test123')
      assert_equal false, user.authenticate('test123')

      assert_equal true, user.authenticate_with_password('abc123')
      assert_equal true, user.authenticate(:password, 'abc123')
      assert_equal true, user.authenticate('abc123')

      # By api key
      allow(user).to receive(:api_key).and_return('this-is-my-api-key')

      assert_equal true, user.authenticate_with_api_key('this-is-my-api-key')
      assert_equal true, user.authenticate_with_api_key('this-is-my-api-key')

      assert_equal false, user.authenticate_with_api_key('this-is-not-my-api-key')
      assert_equal false, user.authenticate_with_api_key('this-is-not-my-api-key')

      # With an unknown authentication method
      assert_equal false, user.authenticate(:blah, 'sdsd', 'sdlsk')
    end

    it "should be able to change a username" do
      user = create(:user)

      user.password!('test123')
      user.username = 'john'
      user.save

      # reload
      user = User.find_by_id(user.id)

      assert_equal true, user.authenticate('test123')
      assert_equal 'john', user.username

      user.username = 'johndoe'
      user.save

      # reload
      user = User.find_by_id(user.id)

      assert_equal true, user.authenticate('test123')
      assert_equal 'johndoe', user.username
    end

    it "should have successful and failed authentication methods" do
      user = create(:user)

      expect(user.last_session_ip).to be_nil
      expect(user.last_session_at).to be_nil

      expect { user.successful_authentication!('192.168.0.1') }.to change { user.session_count }.by(1)

      expect(user.last_session_ip).to_not be_nil
      expect(user.last_session_at).to_not be_nil

      expect { user.failed_authentication! }.to change { user.failed_auth_count }.by(1)
    end

    it "should calculate an email hash on save" do
      user = build(:user)

      user.email = 'tester@challah.me'
      assert user.save
      assert_equal '859ea8a4ea69b321df4992ca14c08d6b', user.email_hash

      user.email = 'tester-too@challah.me'
      assert user.save
      assert_equal '45ab23dd8eb9a00f61cef27004b38b01', user.email_hash
    end

    it "should have custom authorization providers" do
      user = create(:user)

      auth = ::Authorization.set({
        :user_id => user.id,
        :provider => 'custom',
        :uid => '12345',
        :token => 'abcdef1234569'
      })

      assert_equal false, user.provider?(:password)
      assert_equal nil, user.provider(:password)

      expected_auth = {
        :id => auth.id,
        :uid => '12345',
        :token => 'abcdef1234569',
        :expires_at => nil
      }

      assert_equal true, user.provider?(:custom)
      assert_equal true, user.custom_provider?

      assert_equal expected_auth, user.provider(:custom)
      assert_equal expected_auth, user.custom_provider
    end

    it "should have default method_missing when not looking for a provider" do
      user = create(:user)
      expect(user.custom_provider?).to eq(false)
      expect { user.does_not_exist? }.to raise_error(NoMethodError)
    end

    it "should clear authorizations when removing a user" do
      user = create(:user)

      ::Authorization.set({
        :user_id => user.id,
        :provider => 'custom',
        :uid => '12345',
        :token => 'abcdef1234569'
      })

      user.password!('test123')
      user.save

      expect { user.destroy }.to change { ::Authorization.count }.by(-2)
    end

    it "should set provider attributes" do
      user = build(:user)

      user.provider_attributes = {
        :fake => { :uid => "1", "token" => 'me' }
      }

      assert_equal true, user.provider?(:fake)
      assert_equal true, user.valid_provider?(:fake)

      expect { user.save }.to change { User.count }.by(1)
    end

    it "should not add invalid providers" do
      provider_attributes = {
        "fake" => { :uid => "1", "token" => 'not-me' }
      }

      user = build(:user, :provider_attributes => provider_attributes)

      assert_equal true, user.provider?(:fake)
      assert_equal false, user.valid_provider?(:fake)

      expect { user.save }.to_not change { ::Authorization.count }
    end

    describe "#authenticate" do
      it "authenticates a user" do
        user = build(:user)

        user.password = 'abc123'
        user.password_confirmation = 'abc123'
        assert_equal 'abc123', user.password

        expect { user.save }.to change { User.count }.by(1)

        expect(user.provider?(:password)).to eq(true)
        expect(user.provider(:password)).to_not be_nil

        expect(user.authenticate('abc123')).to eq(true)
        expect(user.authenticate(:password, 'abc123')).to eq(true)
        expect(user.authenticate('test123')).to eq(false)
      end
    end

    describe "#active" do
      let(:user) { build(:user) }

      it "is true if status is :active" do
        user.status = :active
        expect(user.active?).to eq(true)
        expect(user.active).to eq(true)
      end

      it "is false if status is not :active" do
        user.status = :inactive
        expect(user.active?).to eq(false)
        expect(user.active).to eq(false)
      end
    end

    describe "#active=" do
      let(:user) { build(:user) }

      it "sets the status column to active" do
        user.status = :inactive
        expect(user.active?).to eq(false)

        user.active = true
        expect(user.active?).to eq(true)
      end

      it "sets the status column to inactive" do
        user.status = :active
        expect(user.active?).to eq(true)

        user.active = false
        expect(user.active?).to eq(false)
      end
    end

    describe "#email" do
      context "with an existing user" do
        let(:existing) { create(:user, email: "admin@challah.me") }
        let(:duplicate) { build(:user, email: "admin@challah.me") }

        before do
          existing
        end

        it "requires a unique email" do
          expect(duplicate.valid?).to eq(false)
          expect(duplicate.errors).to include(:email)
        end
      end
    end

    describe ".active" do
      before do
        create_list(:user, 3, status: :active)
        create_list(:user, 2, status: :inactive)
      end

      it "is a relation" do
        expect(User.active).to be_kind_of(ActiveRecord::Relation)
      end

      it "returns the active users" do
        expect(User.active.count).to eq(3)
      end
    end

    describe ".inactive" do
      before do
        create_list(:user, 3, status: :active)
        create_list(:user, 2, status: :inactive)
      end

      it "is a relation" do
        expect(User.inactive).to be_kind_of(ActiveRecord::Relation)
      end

      it "returns the inactive users" do
        expect(User.inactive.count).to eq(2)
      end
    end
  end
end
