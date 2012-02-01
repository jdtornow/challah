module Challah
  # AuthableRole is used to extend functionality to a model in your app named Role. By default, 
  # this model already exists within the challah engine.
  #
  # The Role model is used to group together sets of permissions that can be assigned
  # to users. 
  #
  # Roles are not used to detect features or options for a user. Instead, you should 
  # always use permissions as the most granular level of detail within your app.
  #
  # For example, to restrict a piece of your application to a certain user, you should create
  # a new permission level that restricts it. Then, you can assign that permission to roles
  # and users on an ad hoc basis.
  #
  # In most cases roles should not be accessed directly, and only be used as a means to
  # quickly assign a user to several permissions. In other words, checking to see what role
  # a user is assigned to in your app is probably not a great idea. Use permission checks instead.
  #
  # The administrator role, which is included in the seeds file by default, is automatically
  # able to access all permissions. All subsequently added permissions will also be added
  # to the administrator role.
  #
  # == Validations
  # 
  # A role requires that a unique name be provided.
  #  
  # == Associations
  #
  # The following associations are set on this model by default:
  #
  # * Has many *users* (connects to {AuthableUser User})
  # * Has many *permissions* (connects to {AuthablePermission Permission})
  #
  # The join table (permission_roles) is also included, but likely does not need to be
  # accessed directly.
  #
  # == Customizing the Role model
  #
  # By default, the Role model is included within the gem engine. However, if you wish to 
  # include it within your app for any customizations, you can do so by creating a model 
  # file named +role.rb+ and adding the +authable_role+ line near the top of the class.
  # 
  # @example app/models/role.rb
  #   class Role < ActiveRecord::Base
  #     # Set up all role methods from challah gem
  #     authable_role  
  #
  #     # Your customizations here..
  #   end
  module AuthableRole
    # This method sets up the +Role+ class with all baked in methods.
    #
    # A role requires the presence of the +name+ and +default_path+ attributes.
    #
    # Once this method has been called, the {InstanceMethods} and {ClassMethods} modules
    # will be accessibile within the Role model.
    def authable_role
      unless included_modules.include?(InstanceMethods)
        include InstanceMethods
        extend ClassMethods
      end
      
      class_eval do
        validates_presence_of :name
        validates_uniqueness_of :name
        
        has_many :users, :order => 'users.first_name, users.last_name'
        has_many :permission_roles, :dependent => :destroy
        has_many :permissions, :through => :permission_roles, :order => 'permissions.name'
      
        default_scope order('roles.name')

        after_save :save_permission_keys
      end
    end
  
    module ClassMethods
      # Quickly access a +Role+ instance by the provided name. If no +Role+
      # is found with that key, +nil+ is returned.
      #
      # @param [Symbol, String] name A role +name+ to locate.
      # @return [Role, nil]
      #
      # @example
      #   Role[:administrator]        # => Role.find_by_name('administrator')
      #   Role['User Manager']        # => Role.find_by_name('user manager')
      #   Role[:does_not_exist]       # => nil
      def [](name)
        self.find_by_name(name.to_s.strip.downcase.gsub(' ', '_').titleize)
      end
      
      # Shortcut for finding the Role named 'Administrator'
      #
      # @return [Role, nil]
      #
      # @example
      #   Role.admin # => Role.find_by_name('administrator')
      def admin
        @admin ||= self.find_by_name('Administrator')
      end
    end
  
    module InstanceMethods
      # Grab all permission keys for this +Role+
      #
      # Note that this returns <i>permission keys</i>, not Permission instances.
      #
      # @return [Array] List of permission keys registered to this role.
      #
      # @see #permission_keys=
      def permission_keys
        @permission_keys ||= self.permissions.collect(&:key)
      end

      # Set the permission keys that this role can access. This temporarily updates
      # the permission keys for the +Role+ instance, but changes are not saved until 
      # the model has been saved.
      #
      # @param [Array] keys An array of permission keys to set for this role.
      # @return [Array] List of permission keys updated.
      #
      # @see #permission_keys=
      def permission_keys=(keys)
        @permission_keys = keys
        @permission_keys
      end
      
      # Does this role have the given +Permission+? Pass in a Permission instance, or
      # a permission key to check for its existance.
      #
      # @param [Permission, String, Symbol] permision_or_key The permission to check for.
      # @return [Boolean] Does this role have the given permission?
      #
      # @see #permission_keys
      def has(permision_or_key)
        symbolized_key = ::Permission === permision_or_key ? permision_or_key[:key] : permision_or_key.to_s
        permission_keys.include?(symbolized_key)
      end
      alias_method :permission?, :has

      # Customized +method_missing+ call that can be used to detect whether a role
      # has a given permission. This passes a key to the {#has} method.
      #
      # @example
      #   role.admin?               # => role.has(:admin)
      #   role.my_permission?       # => role.has(:my_permission)
      #
      # @see #has
      def method_missing(sym, *args, &block)
        return has(sym.to_s.gsub(/\?/, '')) if sym.to_s =~ /^[a-z0-9_]*\?$/
        super(sym, *args, &block)
      end
    
      protected
        # @private
        #
        # Save the permission keys that were updated using +permission_keys=+
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