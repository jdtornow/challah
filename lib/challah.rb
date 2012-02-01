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
      
      helper_method :logged_in?, :current_user, :current_user_session, :current_user?
    end
  end
  
  # Configuration options  
  class << self
    def options
      @options ||= {
        :storage_class => CookieStore,
        :cookie_prefix => 'challah'
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