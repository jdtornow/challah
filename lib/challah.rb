require 'challah/audit'
require 'challah/authable/permission'
require 'challah/authable/permission_role'
require 'challah/authable/permission_user'
require 'challah/authable/role'
require 'challah/authable/user'
require 'challah/controller'
require 'challah/cookie_store'
require 'challah/encrypter'
require 'challah/random'
require 'challah/session'
require 'challah/techniques'
require 'challah/version'

module Challah
  if defined? Rails::Engine
    class Engine < Rails::Engine
      initializer 'challah.router' do |app|
        app.routes_reloader.paths.insert(0, File.expand_path(File.join(File.dirname(__FILE__), 'challah/routes.rb')))
      end
    end
  end
  
  if defined? ::ActiveRecord
    # @private
    class ::ActiveRecord::Base
      include Audit
      extend AuthablePermission
      extend AuthablePermissionRole
      extend AuthablePermissionUser
      extend AuthableRole
      extend AuthableUser      
    end
  end
  
  if defined? ::ActionController
    # @private
    class ::ActionController::Base
      include Controller
      
      helper_method :logged_in?, :current_user, :current_user_session, :current_user?, :has
    end
  end
  
  # Configuration options  
  class << self
    # Get or set options for the current Challah instance. In most cases these should be
    # changed within a config/initializers/ file in your app.
    #
    # @param [Hash] options The options to get or set
    # @option options [String] :cookie_prefix ('challah') A prefix to put in the names of the cookies that will be set.
    # @option options [String] :access_denied_view ('challah/sessions/access_denied')Relative path to the view that will be used to show access denied method.
    # @option options [Class] :storage_class (CookieStore) The class to use for persistence of sessions.
    def options
      @options ||= {
        :cookie_prefix => 'challah',
        :access_denied_view => 'challah/sessions/access_denied',
        :storage_class => CookieStore
      }
    end
  end
  
  # Set up techniques engines
  extend Techniques
  @techniques ||= {}
  
  # Default registered authentication techiques.   
  register_technique :password,       PasswordTechnique
  register_technique :api_key,        ApiKeyTechnique
end