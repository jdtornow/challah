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
      return $challah_test_session.to_s.split(':')
    end

    nil
  end

  def save(token, user_id)
    $challah_test_session = "#{token}:#{user_id}"
    true
  end
end

Challah.options[:storage_class] = TestSessionStore

class ActiveSupport::TestCase
  # Log the given user instance in
  def login_as(user)
    Challah::Session.create!(user)
  end

  # Log the given user instance out
  def logout
    Challah::Session.destroy
  end

  setup do
    # Reset any challah user sessions for each test.
    $challah_test_session = nil
  end
end