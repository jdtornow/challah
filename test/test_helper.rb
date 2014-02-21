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

Dir["#{ File.dirname(__FILE__) }/support/**/*.rb"].each { |f| require f }

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  fixtures :all

  include FactoryGirl::Syntax::Methods

  self.use_transactional_fixtures = true
end

