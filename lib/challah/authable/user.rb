module Challah
  module AuthableUser
    def authable_user
      unless included_modules.include?(InstanceMethods)
        include InstanceMethods
        extend ClassMethods
      end

      class_eval do
        cattr_accessor :protected_attributes

        validates_presence_of :first_name, :last_name, :email, :role_id, :username
        validates_uniqueness_of :email, :username
        validate :validate_new_password

        before_save :before_save_password

        belongs_to :role, :touch => true
        has_many :permission_users, :dependent => :destroy
        has_many :permissions, :through => :permission_users, :order => 'permissions.name'

        scope :active, where(:active => true).order('users.first_name, users.last_name')
        scope :inactive, where(:active => false).order('users.first_name, users.last_name')
        scope :with_role, lambda { |role| where([ "users.role_id = ?", role ]) }
        scope :search, lambda { |q| where([ 'users.first_name like ? OR users.last_name like ? OR users.email like ? OR users.username LIKE ?', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%" ]) }
        after_save :save_permission_keys

        attr_accessible :first_name, :last_name, :username, :email, :password, :password_confirmation

        protect_attributes :api_key, :created_by, :crypted_password, :failed_login_count, :id, :last_session_at, :last_login_at, :last_session_ip, :login_count, :permissions, :permissions_attributes, :permission_users, :permission_users_attributes, :persistence_token, :role_id, :session_count, :updated_by
      end
    end

    module ClassMethods
      # Find a user instance by username first, or email address if needed.
      # If no user is found matching, return nil
      def find_for_session(username_or_email)
        return nil if username_or_email.to_s.blank?

        result = nil

        result = find_by_username(username_or_email)

        unless result
          if username_or_email.to_s.include?('@')
            result = find_by_email(username_or_email)
          end
        end

        result
      end

      def protect_attributes(*args)
        self.protected_attributes ||= []
        self.protected_attributes << args.collect(&:to_s)
      end
    end

    # Instance methods to be included once authable_user is set up.
    module InstanceMethods
      # Returns true if this user is active, and should be able to log in. If
      # the active column is false, the user will not be able to authenticate
      def active?
        !!self.active
      end

      # Generic authentication method. By default, this just checks to see if the password
      # given matches this user. You can also pass in the first parameter as the method
      # to use for a different type of authentication.
      def authenticate(*args)
        return false unless active?

        if args.length > 1
          method = args.shift

          if respond_to?("authenticate_with_#{method}")
            return self.send("authenticate_with_#{method}", *args)
          end

          false
        else
          authenticate_with_password(args[0])
        end
      end

      # Pass in an api_key, and if it matches this user account, return true.
      def authenticate_with_api_key(api_key)
        self.api_key == api_key
      end

      # Pass in a password, and if it matches this user's account, return true.
      def authenticate_with_password(plain_password)
        ::Challah::Encrypter.compare(self.crypted_password, plain_password)
      end

      # The default url where this user should be redirected to after logging in. Also can be used as the main link
      # at the top of navigation.
      def default_path
        role ? role.default_path : '/'
      end

      def failed_authentication!
        self.increment!(:failed_auth_count)
      end

      # full name
      def name
        "#{first_name} #{last_name}"
      end

      # Get the value of the current password, only can be used right after setting a new password.
      def password
        @password
      end

      # Set a password for this user
      def password=(value)
        if value.to_s.blank?
          @password = nil
          @password_updated = false
        else
          @password = value
          @password_updated = true
        end
      end

      # Set the confirmation when changing a password
      def password_confirmation=(value)
        @password_confirmation = value
      end

      # Returns the permission keys in an array for exactly what this user can access. This includes all role based permission keys, and any specifically given to this user through permissions_users
      def permission_keys
        return @permission_keys if @permission_keys

        role_keys = if role(true)
          role_key = "#{role.cache_key}/permissions"

          keys = Rails.cache.fetch(role_key) do
            role.permission_keys.clone
          end

          Rails.cache.write(role_key, keys)
          keys
        else
          []
        end

        user_key = "#{self.cache_key}/permissions"

        user_keys = Rails.cache.fetch(user_key) do
          user_permission_keys.clone
        end

        user_keys = [] unless user_keys

        Rails.cache.write(user_key, keys) unless new_record?

        @permission_keys = (role_keys + user_keys).uniq
      end

      # Returns true if this user has permission to the provided permission key
      def has(permission_key)
        self.permission_keys.include?(permission_key.to_s)
      end
      alias_method :permission?, :has

      # Set the permission keys that this role can access
      def permission_keys=(value)
        Rails.cache.delete("#{self.cache_key}/permissions")

        @permission_keys = value
        @permission_keys
      end

      # When a role is set, reset the permission_keys
      def role_id=(value)
        @permission_keys = nil
        @user_permission_keys = nil

        self[:role_id] = value
      end

      # shortened name, just includes the first name and last initial
      def small_name
        "#{first_name.to_s.titleize} #{last_name.to_s.first.upcase}."
      end

      # Called when a +Session+ validation is successful, and this user has
      # been authenticated.
      def successful_authentication!(ip_address = nil)
        self.last_session_at = Time.now
        self.last_session_ip = ip_address
        self.save
        self.increment!(:session_count, 1)
      end

      # Update a user's own account. This differsfrom User#update_attributes because it won't let
      # a user update their own role and other protected elements.
      #
      # All attributes on the user model can be updated, except for the ones listed below.
      def update_account_attributes(attributes_to_update = {})
        protected_attributes = self.class.protected_attributes.clone.flatten
        attributes_to_update.keys.each { |key| attributes_to_update.delete(key) if protected_attributes.include?(key.to_s) }
        self.update_attributes(attributes_to_update)
      end

      # Returns the permission keys used by this specific user, does not include any role-based permissions.
      def user_permission_keys
        new_record? ? [] : self.permissions(true).collect(&:key)
      end

      # Is this user valid and ready for a user session?
      #
      # Override this method if you need to check for a particular configuration on each page request.
      def valid_session?
        self.active?
      end

      # Allow dynamic checking for permissions
      #
      # +admin?+ is shorthand for:
      #
      #   def admin?
      #     has(:admin)
      #   end
      def method_missing(sym, *args, &block)
        return has(sym.to_s.gsub(/\?/, '')) if sym.to_s =~ /^[a-z_]*\?$/
        super(sym, *args, &block)
      end

      protected
        # called before_save on the User model, actually encrypts the password with a new generated salt
        def before_save_password
          if @password_updated and valid?
            self.crypted_password = ::Challah::Encrypter.encrypt(@password)

            @password_updated = false
            @password = nil
          end

          self.persistence_token = ::Challah::Random.token(125) if self.persistence_token.to_s.blank?
          self.api_key = ::Challah::Random.token(50) if self.api_key.to_s.blank?
        end

        # Saves any updated permission keys to the database for this user.
        # Any permission keys that are specifically given to this user and are also in the
        # user's role will be removed. So, the only permission keys added here will be those
        # in addition to the user's role.
        def save_permission_keys
          if @permission_keys and Array === @permission_keys
            self.permission_users(true).clear

            @permission_keys = @permission_keys.uniq - self.role.permission_keys

            @permission_keys.each do |key|
              permission = ::Permission[key]

              if permission
                self.permission_users.create(:permission_id => permission.id, :user_id => self.id)
              end
            end

            @permission_keys = nil
            @user_permission_keys = nil

            self.permissions(true).collect(&:key)
          end
        end

        # validation call for new passwords, make sure the password is confirmed, and is >= 4 characters
        def validate_new_password
          if new_record? and self.read_attribute(:crypted_password).to_s.blank? and !@password_updated
            errors.add :password, :blank
          elsif @password_updated
            if @password.to_s.size < 4
              errors.add :password, :invalid_password
            elsif @password.to_s != @password_confirmation.to_s
              errors.add :password, :no_match_password
            end
          end
        end
    end
  end
end