require 'helper'

class SignupTest < ActiveSupport::TestCase
  context "A user" do
    should "sign up for an app with a password" do
      signup = Challah::Signup.new
      signup.first_name             = 'Avon'
      signup.last_name              = 'Barksdale'
      signup.email                  = 'avon@challah.me'
      signup.password               = 'test123'
      signup.password_confirmation  = 'test123'

      assert_difference [ 'User.count', 'Authorization.count' ], 1 do
        assert signup.save, 'Signup could not save!'
      end

      assert_equal false, signup.new_record?
      assert_equal "Avon Barksdale", signup.user.name
      assert_equal true, signup.user.authenticate_with_password('test123')
      assert_equal :password, signup.provider
    end

    should "sign up using a params hash" do
      user_params = {
        first_name: 'Stringer',
        last_name:  'Bell',
        email:      'stringer@challah.me',
        password:   'abc123',
        password_confirmation: 'abc123'
      }

      signup = Challah::Signup.new(user_params)

      assert_difference [ 'User.count', 'Authorization.count' ], 1 do
        assert signup.save, 'Signup could not save'
      end

      assert_equal false, signup.new_record?
      assert_equal 'Stringer Bell', signup.user.name
      assert_equal true, signup.user.authenticate_with_password('abc123')
    end

    should "not sign up without a password" do
      signup = Challah::Signup.new
      signup.first_name             = 'Avon'
      signup.last_name              = 'Barksdale'
      signup.email                  = 'avon@challah.me'

      assert_no_difference [ 'User.count', 'Authorization.count' ] do
        assert_equal false, signup.save
      end

      assert_equal true, signup.new_record?
      assert_equal "Avon Barksdale", signup.user.name
      assert_equal :password, signup.provider
    end

    should "sign up with another valid provider" do

    end

    should "not sign up without any providers" do

    end

    should "not sign up with an invalid provider" do

    end
  end
end