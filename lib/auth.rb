require 'auth/audit'
require 'auth/encrypter'
require 'auth/random'
require 'auth/active_record'
require 'auth/version'

module Auth
  if defined? Rails::Engine
    class Engine < Rails::Engine
    end
  end
  
  if defined? ActiveRecord
    class ActiveRecord::Base
      include Audit
      include Authable::Permission
      include Authable::PermissionRole
      include Authable::PermissionUser
      include Authable::Role
      include Authable::User      
    end
  end
end