require 'challah/authenticators/api_key'
require 'challah/authenticators/password'

module Challah
  module Authenticators
    # Register a new authenticator.
    #
    # Usage:
    #
    #     Challah.register_authenticator(:facebook, FacebookAuthenticator)
    #
    # Each authenticator class should have a class method named match?
    # that takes a user and a number of arguments and returns true or false.
    def register_authenticator(name, klass)
      @authenticators[name] = klass
    end

    # Get the list of all authenticators that have been registered.
    def authenticators
      @authenticators.dup
    end
  end
end