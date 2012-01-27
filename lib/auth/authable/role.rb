module Auth
  module Authable
    module Role
      def self.included(base)
        base.extend(AuthableMethods)
      end
    
      module AuthableMethods
        def authable_role
          unless included_modules.include?(InstanceMethods)
            include InstanceMethods
            extend ClassMethods
          end
          
          class_eval do
            validates_presence_of :name, :default_path
            validates_uniqueness_of :name
            
            has_many :users, :order => 'users.first_name, users.last_name'
            has_many :permission_roles, :dependent => :destroy
            has_many :permissions, :through => :permission_roles, :order => 'permissions.name'
          
            default_scope order('roles.name')

            after_save :save_permission_keys
          end
        end
      
        module ClassMethods
          def [](value)
            self.find_by_name(value.to_s.strip.downcase.gsub(' ', '_').titleize)
          end
          
          def admin
            @admin ||= self.find_by_name('Administrator')
          end
        end
      
        module InstanceMethods
          # Returns the permission keys in an array for exactly what this role can access
          def permission_keys
            @permission_keys ||= self.permissions.collect(&:key)
          end

          # Set the permission keys that this role can access
          def permission_keys=(value)
            @permission_keys = value
            @permission_keys
          end
          
          # Returns true if this role has permission to the provided permission key
          def permission?(key)
            symbolized_key = ::Permission === key ? key.key : key.to_s
            permission_keys.include?(key.to_s)
          end
          alias :has :permission?

          # Allow dynamic checking for permissions
          # 
          # +admin?+ is shorthand for:
          #
          #   def admin?
          #     has(:admin)
          #   end
          def method_missing(sym, *args, &block)
            return has(sym.to_s.gsub(/\?/, '')) if sym.to_s =~ /^[a-z0-9_]*\?$/
            super(sym, *args, &block)
          end
        
          protected
            def save_permission_keys              
              if @permission_keys and Array === @permission_keys
                self.permission_roles(true).clear

                @permission_keys.uniq.each do |key|
                  permission = ::Permission.find_by_key(key)
                  
                  if permission
                    self.permission_roles.create(:permission_id => permission.id, :role_id => self.id)
                  end
                end

                @permission_keys = nil

                self.permissions(true).collect(&:key)
              end
            end
        end
      end
    end
  end
end