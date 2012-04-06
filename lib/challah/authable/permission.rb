module Challah
  # AuthablePermission is used to extend functionality to a model in your app named Permission.
  # By default, this model already exists within the challah engine.
  #
  # The Permission model is used to store every granular level of restriction for your application.
  # If there is anything within your app that may need to be restricted in any way, you'll likely
  # want to create a permission for it.
  #
  # Permission can be as granular as necessary. For example, you may have a permission called
  # +:people_admin+. Or, you could specify each action taken within an admin section, and add permissions
  # for each of them: +:add_people+, +:edit_people+, +:list_people+, +:delete_people+. Obviously this
  # can be overkill if your app is large, but you get the idea.
  #
  # == Validations
  #
  # A valid permission requires a unique name and key to be provided. The key must be all lower case
  # letters, numbers and underscores only.
  #
  # == Associations
  #
  # The following associations are set on this model by default:
  #
  # * Has many *roles* (connects to {AuthableRole Role})
  # * Has many *users* (connects to {AuthableUser User})
  #
  # The join tables (permission_roles and permission_users) are also included, but likely do not
  # need to be accessed directly.
  #
  # == Scopes
  #
  # By default, the following scopes are included for this model:
  #
  # * default - order by name
  #
  # == Customizing the Permission model
  #
  # By default, the Permission model is included within the gem engine. However, if you wish to
  # include it within your app for any customizations, you can do so by creating a model
  # file named +permission.rb+ and adding the +authable_permission+ line near the top of the class.
  #
  # @example app/models/permission.rb
  #   class Permission < ActiveRecord::Base
  #     # Set up all permission methods from challah gem
  #     authable_permission
  #
  #     # Your customizations here..
  #   end
  module AuthablePermission
    # This method sets up the +Permission+ class with all baked in methods.
    #
    # A permission requires the presence of the +name+, +key+ and +description+
    #
    # Once this method has been called, the {InstanceMethods} module
    # will be accessibile within the Permission model.
    def authable_permission
      unless included_modules.include?(InstanceMethods)
        include InstanceMethods
        extend ClassMethods
      end

      class_eval do
        validates_presence_of :name, :key
        validates_uniqueness_of :name, :key
        validates_format_of :key, :with => /^([a-z0-9_])*$/, :message => :invalid_key

        has_many :permission_roles, :dependent => :destroy
        has_many :roles, :through => :permission_roles, :order => 'roles.name'
        has_many :permission_users, :dependent => :destroy
        has_many :users, :through => :permission_users, :order => 'users.last_name, users.first_name'

        default_scope order('permissions.name')

        attr_accessible :name, :description, :key, :locked

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
      #   Permission['manage_users'] # => Permission.find_by_key('manage_users')
      #   Permission[:does_not_exist] # => nil
      def [](key)
        self.find_by_key(key.to_s.strip.downcase.gsub(' ', '_'))
      end
    end

    # @private
    module InstanceMethods
      # @private
      #
      # When setting a key, make sure it is lower cased and free from padded whitespace.
      def key=(value)
        write_attribute(:key, value.to_s.downcase.strip)
      end

      protected
        # @private
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