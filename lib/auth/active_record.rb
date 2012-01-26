require 'active_record'
require 'auth/authable/permission'
require 'auth/authable/permission_role'
require 'auth/authable/permission_user'
require 'auth/authable/role'
require 'auth/authable/user'

# @private
class ActiveRecord::Base
  include Auth::BigBrother
  include Auth::Authable::Permission
  include Auth::Authable::PermissionRole
  include Auth::Authable::PermissionUser
  include Auth::Authable::Role
  include Auth::Authable::User
end