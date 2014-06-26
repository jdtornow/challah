require "challah/version"

module Challah
  autoload :Audit,                            "challah/audit"

  autoload :CookieStore,                      "challah/cookie_store"
  autoload :SimpleCookieStore,                "challah/simple_cookie_store"

  autoload :Authenticators,                   "challah/authenticators"
  autoload :Controller,                       "challah/controller"
  autoload :Encrypter,                        "challah/encrypter"
  autoload :Plugins,                          "challah/plugins"
  autoload :Providers,                        "challah/providers"
  autoload :Random,                           "challah/random"
  autoload :Session,                          "challah/session"
  autoload :Signup,                           "challah/signup"
  autoload :Techniques,                       "challah/techniques"
  autoload :Techniques,                       "challah/techniques"

  autoload :EmailValidator,                   "challah/validators/email_validator"
  autoload :PasswordValidator,                "challah/validators/password_validator"

  autoload :PasswordProvider,                 "challah/providers/password_provider"

  autoload :ActiveRecordExtensions,           "challah/active_record_extensions"

  autoload :Authorizeable,                    "challah/concerns/authorizeable"
  autoload :Userable,                         "challah/concerns/userable"
  autoload :UserAttributeable,                "challah/concerns/user/attributeable"
  autoload :UserAuthenticateable,             "challah/concerns/user/authenticateable"
  autoload :UserAuthorizable,                 "challah/concerns/user/authorizable"
  autoload :UserFindable,                     "challah/concerns/user/findable"
  autoload :UserPasswordable,                 "challah/concerns/user/passwordable"
  autoload :UserProvideable,                  "challah/concerns/user/provideable"
  autoload :UserValidateable,                 "challah/concerns/user/validateable"

  # Configuration options
  # Get or set options for the current Challah instance. In most cases these should be
  # changed within a config/initializers/ file in your app.
  #
  # @param [Hash] options The options to get or set
  # @option options [String] :cookie_prefix ("challah") A prefix to put in the names of the cookies that will be set.
  # @option options [String] :access_denied_view ("challah/sessions/access_denied")Relative path to the view that will be used to show access denied method.
  # @option options [Class] :storage_class (SimpleCookieStore) The class to use for persistence of sessions.
  # @option options [Boolean] :skip_routes (false) Pass in true to not add any routes into your Rails app by default.
  # @option options [String] :email_validator ("challah/email") Pass in a string name of the class to use for email validation. Class should inherit from ActiveModel::EachValidator
  # @option options [Class] :password_validator (Challah::PasswordValidator) Pass in a class to use for password validation.
  def self.options
    @options ||= {
      access_denied_view:     "sessions/access_denied",
      api_key_enabled:        false,
      cookie_prefix:          "challah",
      email_validator:        "challah/email",
      password_validator:     PasswordValidator,
      skip_routes:            false,
      skip_user_validations:  false,
      storage_class:          SimpleCookieStore,
      user:                   :User
    }
  end

  def self.user
    options[:user].to_s.safe_constantize
  end

  # Set up techniques engines
  extend Techniques
  @techniques ||= {}

  # Default registered authentication techiques.
  register_technique :api_key,        ApiKeyTechnique
  register_technique :password,       PasswordTechnique

  # Set up plugin registering capability
  extend Plugins
  @plugins ||= {}

  # Set up authenticators
  extend Authenticators
  @authenticators ||= {}

  # Default registered authentication techiques.
  register_authenticator :api_key,    Authenticators::ApiKey
  register_authenticator :password,   Authenticators::Password

  # Set up authorization providers
  extend Providers
  @providers ||= {}

  register_provider :password, PasswordProvider
end

require "challah/engine" if defined?(Rails)
