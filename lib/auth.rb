require 'auth/active_record'
require 'auth/audit'
require 'auth/controller'
require 'auth/cookie_store'
require 'auth/encrypter'
require 'auth/random'
require 'auth/session'
require 'auth/techniques'
require 'auth/version'

module Auth
  if defined? Rails::Engine
    class Engine < Rails::Engine
    end
  end
  
  if defined? ::ActiveRecord
    # @private
    class ::ActiveRecord::Base
      include Audit
      include Authable::Permission
      include Authable::PermissionRole
      include Authable::PermissionUser
      include Authable::Role
      include Authable::User      
    end
  end
  
  if defined? ::ActionController
    # @private
    class ::ActionController::Base
      include Controller
      
      helper_method :signed_in?, :current_user, :current_user_session, :current_user?
    end
  end
  
  extend Techniques  
  @techniques ||= {}
  
  # Default registered authentication techiques.   
  register_technique :password,       PasswordTechnique
  register_technique :api_key,        ApiKeyTechnique
  
  # By default, store session persistence in cookies.
  Auth::Session.storage_class = CookieStore
  
  # Name the CookieStore cookie prefixes
  CookieStore.prefix = 'auth'
end