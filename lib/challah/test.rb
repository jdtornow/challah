module Challah
  # Used to persist session data in test mode instead of using cookies. Stores the session
  # data lazily in a global var, accessible across the testing environment.
  class TestSessionStore
    def initialize(session = nil)
      @session = session
    end

    def destroy
      $challah_test_session = nil
    end

    def read
      if $challah_test_session
        return $challah_test_session.to_s.split("@")
      end

      nil
    end

    def save(token, user_id)
      $challah_test_session = "#{ token }@#{ user_id }"
      true
    end
  end

  module Testing

    # Sign the given user instance in
    def signin_as(user)
      Session.create!(user, nil, nil, user.class)
    end
    alias_method :login_as, :signin_as

    # Sign the given user instance out
    def signout
      Session.destroy
    end
    alias_method :logout, :signout

  end
end

if defined?(ActionController::TestCase)
  Challah.options[:storage_class] = Challah::TestSessionStore

  class ActionController::TestCase
    include Challah::Testing

    setup do
      $challah_test_session = nil
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |config|

    config.before(:all) do
      # make sure challah is using test session in test mode
      Challah.options[:storage_class] = Challah::TestSessionStore
    end

    config.before(:each) do
      # Reset any challah user sessions for each test.
      $challah_test_session = nil
    end

    config.include Challah::Testing, type: :controller

  end
end
