require 'spec_helper'

module Challah
  # TODO make these specs not look like unit tests
  describe Signup do

    it "should be properly named" do
      assert_equal "Signup", Challah::Signup.model_name
    end

    it "should sign up for an app with a password" do
      signup = Challah::Signup.new
      signup.first_name             = 'Avon'
      signup.last_name              = 'Barksdale'
      signup.email                  = 'avon@challah.me'
      signup.password               = 'test123'
      signup.password_confirmation  = 'test123'

      expect { signup.save }.to change { User.count }.by(1)

      assert_equal false, signup.new_record?
      assert_equal "Avon Barksdale", signup.user.name
      assert_equal true, signup.user.authenticate_with_password('test123')
      assert_equal :password, signup.provider
    end

    it "should sign up using a params hash" do
      user_params = {
        first_name: 'Stringer',
        last_name:  'Bell',
        email:      'stringer@challah.me',
        password:   'abc123',
        password_confirmation: 'abc123'
      }

      signup = Challah::Signup.new(user_params)

      expect { signup.save }.to change { User.count }.by(1)

      assert_equal false, signup.new_record?
      assert_equal 'Stringer Bell', signup.user.name
      assert_equal true, signup.user.authenticate_with_password('abc123')
    end

    it "should not sign up without a password" do
      signup = Challah::Signup.new
      signup.first_name   = 'Avon'
      signup.last_name    = 'Barksdale'
      signup.email        = 'avon@challah.me'

      expect { signup.save }.to_not change { User.count }

      assert_equal true, signup.new_record?
      assert_equal "Avon Barksdale", signup.user.name
      assert_equal :password, signup.provider
    end

    it "should sign up with another valid provider" do
      signup = Challah::Signup.new
      signup.first_name   = 'Avon'
      signup.last_name    = 'Barksdale'
      signup.email        = 'avon@challah.me'
      signup.provider     = "fake"
      signup.password     = ""
      signup.password_confirmation = ""
      signup.provider_attributes = { "fake" => { "uid" => "1", "token" => "me" } }

      expect { signup.save }.to change { User.count }.by(1)

      assert_equal :fake, signup.provider
      assert_equal "me", signup.user.providers[:fake].fetch(:token)
    end

    it "should not sign up without any providers" do
      signup = Challah::Signup.new
      signup.first_name   = 'Avon'
      signup.last_name    = 'Barksdale'
      signup.email        = 'avon@challah.me'
      signup.provider     = nil

      expect { signup.save }.to_not change { User.count }

      assert_equal true, signup.new_record?
      assert_equal "Avon Barksdale", signup.user.name
      assert_equal nil, signup.provider
    end

    it "should not sign up with an invalid provider" do
      signup = Challah::Signup.new
      signup.first_name   = 'Avon'
      signup.last_name    = 'Barksdale'
      signup.email        = 'avon@challah.me'
      signup.provider     = "blank"
      signup.provider_attributes = { "blank" => { "uid" => "1", "token" => "1" } }

      expect { signup.save }.to_not change { User.count }

      assert_equal true, signup.new_record?
      assert_equal "Avon Barksdale", signup.user.name
      assert_equal :blank, signup.provider
    end

    it "should consolidate error messages" do
      signup = Challah::Signup.new
      assert_equal false, signup.save
      expected_error_fields = [ :first_name, :last_name, :email, :password ].sort
      assert_equal expected_error_fields, signup.errors.messages.keys.sort
    end
  end
end
