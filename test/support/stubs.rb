class MockController
  include Challah::Controller

  attr_accessor :request, :session, :params

  def initialize()
    @request = MockRequest.new
    @session ||= {}
    @params ||= {}
  end

  def redirect_to(*args)
    # do nothing
  end

  def login_path
    "/login"
  end

  def logout_path
    "/logout"
  end

  def signin_path
    "/sign-in"
  end

  def signout_path
    "/sign-out"
  end
end

class MockRequest
  attr_accessor :cookie_jar, :session_options, :url

  class MockCookieJar < Hash
    def delete(key, options = {})
      super(key)
    end
  end

  def initialize
    @cookie_jar = MockCookieJar.new
    @session_options = { :domain => 'test.dev' }
    @url = "http://example.com/"
  end

  def cookies
    @cookie_jar
  end

  def cookies=(value)
    @cookie_jar = value
  end

  def remote_ip
    "8.8.8.8"
  end

  def user_agent
    "Some Cool Browser"
  end
end

class FakeProvider
  def self.save(record)
    set(record.fake_provider.merge(user_id: record.id))
  end

  def self.set(options = {})
    user_id = options.fetch(:user_id)
    uid     = options.fetch(:uid, '')
    token   = options.fetch(:token, '')

    Authorization.set({
      provider: :fake,
      user_id:  user_id,
      uid:      uid,
      token:    token
    })
  end

  def self.valid?(record)
    record.fake_provider? and record.fake_provider.fetch(:token) == 'me'
  end
end

Challah.register_provider :fake, FakeProvider
