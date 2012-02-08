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

# Load the challah libraries
require 'challah'
require 'challah/test'

# Setup the challah app, including running migrations within the rails app
# TODO - this causes some annoying output in 1.9.3, still works, but would like to suppress
`rake --rakefile #{File.join(sample_root, 'Rakefile')} challah:setup:migrations`

# Run migrations for the sample app, hiding output
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

# Use ActiveSupport::TestCase for any tests using factories and database saving, 
# so we can have a transactional rollback after each test.
class ActiveSupport::TestCase
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