# Coverage reporting, needs to be loaded first to capture all code coverage stats
require 'simplecov'

# Setup a sample rails app for testing rails modules
sample_root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'sampleapp'))
FileUtils.rm_rf(sample_root) if File.exists?(sample_root)
`rails new #{sample_root} --skip-bundle --skip-sprockets`

# Setup environment variables for the Rails instance
ENV['RAILS_ENV'] = 'test'
ENV['BUNDLE_GEMFILE'] ||= File.join(sample_root, 'Gemfile')

# Load the newly created rails instance environment
require "#{sample_root}/config/environment"

# Some other dependencies for testing w/ shoulda and factory girl
require 'shoulda/rails'
require 'mocha'
require 'factory_girl'
require 'factories'
require 'rails/test_help'

# Load the auth libraries
require 'auth'

# Setup the auth app, including running migrations within the rails app
`rake --rakefile #{ File.join(sample_root, 'Rakefile')} auth:setup:migrations`

# Run migrations for the sample app, hiding output
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# Use ActiveSupport::TestCase for any tests using factories and database saving, 
# so we can have a transactional rollback after each test.
class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
end

# Used to persist session data in test mode instead of using cookies. Stores the session
# data lazily in a global var, accessible across the testing environment.
class TestSessionStore
  def initialize(session = nil)
    @session = session
  end
  
  def destroy
    $auth_test_session = nil
  end
  
  def read
    if $auth_test_session
      return $auth_test_session.to_s.split(':')
    end
    
    nil
  end
  
  def save(token, user_id)
    $auth_test_session = "#{token}:#{user_id}"
    true
  end
end

class MockController
  include Auth::Controller
  
  attr_accessor :request
  
  def initialize()
    @request = MockRequest.new
  end
end

class MockRequest
  attr_accessor :cookie_jar, :session_options
  
  class MockCookieJar < Hash
    def delete(key, options = {})
      super(key)
    end
  end
  
  def initialize
    @cookie_jar = MockCookieJar.new
    @session_options = { :domain => 'test.dev' }
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

Auth::Session.storage_class = TestSessionStore

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