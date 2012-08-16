require 'challah/version'

module Challah
  autoload :Audit,                            'challah/audit'

  autoload :CookieStore,                      'challah/cookie_store'
  autoload :SimpleCookieStore,                'challah/simple_cookie_store'

  autoload :Controller,                       'challah/controller'
  autoload :Encrypter,                        'challah/encrypter'
  autoload :Random,                           'challah/random'
  autoload :Session,                          'challah/session'
  autoload :Techniques,                       'challah/techniques'

  autoload :User,                             'challah/user'

  # Configuration options
  class << self
    attr_accessor :user_model

    # Get or set options for the current Challah instance. In most cases these should be
    # changed within a config/initializers/ file in your app.
    #
    # @param [Hash] options The options to get or set
    # @option options [String] :cookie_prefix ('challah') A prefix to put in the names of the cookies that will be set.
    # @option options [String] :access_denied_view ('challah/sessions/access_denied')Relative path to the view that will be used to show access denied method.
    # @option options [Class] :storage_class (SimpleCookieStore) The class to use for persistence of sessions.
    def options
      @options ||= {
        :api_key_enabled => false,
        :cookie_prefix => 'challah',
        :access_denied_view => 'sessions/access_denied',
        :storage_class => SimpleCookieStore,
        :skip_routes => false
      }
    end
  end

  # Set up techniques engines
  extend Techniques
  @techniques ||= {}

  # Default registered authentication techiques.
  register_technique :api_key,        ApiKeyTechnique
  register_technique :password,       PasswordTechnique
end

require 'challah/railtie' if defined?(Rails)