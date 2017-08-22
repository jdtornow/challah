require "simplecov"

# Configure Rails Environment
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "pry"

Rails.backtrace_cleaner.remove_silencers!

db_files = Dir["#{ Rails.root.join("db") }/**/*challah*.rb"]

# Allow repeat tests to run, dropping the db after each suite run
# (*not called on CI server)
if db_files.size > 0
  `rake --rakefile #{ File.expand_path("../dummy/Rakefile",  __FILE__) } db:test:purge`

  FileUtils.rm_rf(db_files)
  FileUtils.rm_rf(Rails.root.join("db", "schema.rb"))
end

`cd #{ File.expand_path("../dummy",  __FILE__) } && ./bin/rails g challah`
`rake --rakefile #{ File.expand_path("../dummy/Rakefile",  __FILE__) } db:migrate db:test:prepare`

require "rspec/rails"
require "factory_girl"
require "challah/test"

# Load support files
Dir["#{ File.dirname(__FILE__) }/support/**/*.rb"].each { |f| require f }
Dir["#{ File.dirname(__FILE__) }/factories/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{ ::Rails.root }/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.infer_spec_type_from_file_location!
end
