# Coverage reporting, needs to be loaded first to capture all code coverage stats
require 'simplecov'

# Configure Rails Environment
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

# Some other dependencies for testing w/ shoulda and factory girl
require 'shoulda'
require 'mocha/setup'
require 'factory_girl'
require 'factories'
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

# Load the challah libraries
require 'challah'
require 'challah/test'

db_files = Dir["#{ Rails.root.join("db") }/**/*challah*.rb"]

# Allow repeat tests to run, dropping the db after each suite run
# (*not called on CI server)
if db_files.size > 0
  `rake --rakefile #{ File.expand_path("../dummy/Rakefile",  __FILE__) } db:test:purge`

  FileUtils.rm_rf(db_files)
  FileUtils.rm_rf(Rails.root.join("db", "schema.rb"))
end

`rake --rakefile #{ File.expand_path("../dummy/Rakefile",  __FILE__) } challah_engine:install:migrations`
`rake --rakefile #{ File.expand_path("../dummy/Rakefile",  __FILE__) } db:migrate`

require 'edge_helper'

# Use ActiveSupport::TestCase for any tests using factories and database saving,
# so we can have a transactional rollback after each test.
class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  self.use_transactional_fixtures = true
end

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

# Monkey patch fix for shoulda and Rails 3.1+.
module Shoulda
  module ActiveRecord
    module Matchers
      class AssociationMatcher
        protected
          def foreign_key
            reflection.foreign_key
          end
      end
    end
  end
end
