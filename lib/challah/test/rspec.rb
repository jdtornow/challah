RSpec.configure do |config|
  config.include Challah::Test::Helpers

  config.before(:each) do
    # Reset any challah user sessions for each test.
    $challah_test_session = nil
  end
end
