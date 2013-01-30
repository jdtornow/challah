class ActiveSupport::TestCase
  include Challah::Test::Helpers

  setup do
    # Reset any challah user sessions for each test.
    $challah_test_session = nil
  end
end
