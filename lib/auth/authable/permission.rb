module Auth
  module Authable
    module Permission
      def self.included(base)
        base.extend(AuthableMethods)
      end
      
      module AuthableMethods
        def authable_permission
          unless included_modules.include?(InstanceMethods)
            include InstanceMethods
            extend ClassMethods
          end
          
          class_eval do
            validates_presence_of :name, :key, :description
            validates_uniqueness_of :name, :key
            validates_format_of :key, :with => /^([a-z_])*$/, :message => :invalid_key

            has_many :permission_roles, :dependent => :destroy
            has_many :roles, :through => :permission_roles, :order => 'roles.name'
            has_many :permission_users, :dependent => :destroy
            has_many :users, :through => :permission_users, :order => 'users.last_name, users.first_name'

            default_scope order('permissions.name')

            after_create :add_to_admin_role
          end
        end
        
        module ClassMethods
          # Quickly access a +Permission+ instance by the provided key. If no +Permission+
          # is found with that key, +nil+ is returned.
          #
          # @param [Symbol, String] key A permission +key+ to locate.
          # @return [Permission, nil]
          #
          # @example
          #   Permission[:admin] # => Permission.find_by_key('admin')
          # @example
          #   Permission['manage_users'] # => Permission.find_by_key('manage_users')
          # @example
          #   Permission[:does_not_exist] # => nil
          def [](key)
            self.find_by_key(key.to_s.strip.downcase.gsub(' ', '_'))
          end      
        end
        
        module InstanceMethods
          def key=(value)
            write_attribute(:key, value.to_s.downcase.strip)
          end
          
          protected
            # After a new permission level is added, automatically add it to the admin user role
            def add_to_admin_role
              admin_role = ::Role.admin
              
              # if there is an admin role, add this permission to it.
              if admin_role
                admin_role.permission_keys = admin_role.permission_keys + [ self.key ]
                admin_role.save
              end
            end
        end
      end
    end
  end
end