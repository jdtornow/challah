require 'simplecov'

# Setup a sample rails app for testing rails modules
SAMPLEAPP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'sampleapp'))
FileUtils.rm_rf(SAMPLEAPP_ROOT) if File.exists?(SAMPLEAPP_ROOT)
`rails new #{SAMPLEAPP_ROOT} --skip-bundle --skip-sprockets`

ENV['RAILS_ENV'] = 'test'
ENV['BUNDLE_GEMFILE'] ||= File.join(SAMPLEAPP_ROOT, 'Gemfile')

RAKE_FILE = File.join(SAMPLEAPP_ROOT, 'Rakefile')

require "#{SAMPLEAPP_ROOT}/config/environment"

require 'shoulda/rails'
require 'mocha'
require 'factory_girl'
require 'factories'
require 'rails/test_help'

require 'auth'

`rake --rakefile #{RAKE_FILE} auth:setup`

# Fixing a bug within shoulda
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