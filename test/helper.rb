ENV["RAILS_ENV"] = "test"
require 'simplecov'
# require File.expand_path('../../config/environment', __FILE__)

require 'mocha'
require 'factory_girl'
require 'factories'
require 'shoulda'
require 'auth'

include Auth

module Shoulda # :nodoc:
  module ActiveRecord # :nodoc:
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