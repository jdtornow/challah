module Challah
  class << self
    # Loop through all registered plugins and extend User functionality.
    def include_user_plugins!
      Challah.plugins.values.each do |plugin|
        plugin.user_extensions.each do |mod|
          ::User.send(:extend, mod)
        end

        plugin.user_init_methods.each do |method_name|
          ::User.send(method_name)
        end
      end
    end
  end

  module User
    def challah_user
      unless included_modules.include?(InstanceMethods)
        include InstanceMethods
        extend ClassMethods
      end

      class_eval do
        cattr_accessor :protected_attributes

        # Validation
        ################################################################

        validates :email,           :presence => true, :uniqueness => true
        validates :first_name,      :presence => true
        validates :last_name,       :presence => true
        validates :username,        :presence => true, :uniqueness => true

        validate :validate_new_password

        # Scoped Finders
        ################################################################

        default_scope       order('users.first_name, users.last_name')

        scope :active,      where(:active => true)
        scope :inactive,    where(:active => false)
        scope :search,      lambda { |q| where([ 'users.first_name like ? OR users.last_name like ? OR users.email like ? OR users.username LIKE ?', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%" ]) }

        # Callbacks
        ################################################################

        before_save         :before_save_password
        before_save         :check_email_hash
        before_validation   :sync_username

        # Attributes
        ################################################################

        attr_accessible     :email,
                            :first_name,
                            :last_name,
                            :password_confirmation,
                            :password,
                            :username

        protect_attributes  :api_key,
                            :created_by,
                            :crypted_password,
                            :failed_login_count,
                            :id,
                            :last_login_at,
                            :last_session_at,
                            :last_session_ip,
                            :login_count,
                            :persistence_token,
                            :role_id,
                            :session_count,
                            :updated_by
      end

      Challah.include_user_plugins!
    end

    module ClassMethods
      # Find a user instance by username first, or email address if needed.
      # If no user is found matching, return nil
      def find_for_session(username_or_email)
        return nil if username_or_email.to_s.blank?

        result = nil

        result = self.where(:username => username_or_email.to_s.strip.downcase).first

        unless result
          if username_or_email.to_s.include?('@')
            result = self.where(:email => username_or_email).first
          end
        end

        result
      end

      # Protect certain attributes of this table from User#update_account_attributes.
      def protect_attributes(*args)
        self.protected_attributes ||= []
        self.protected_attributes << args.collect(&:to_s)
      end
    end

    # Instance methods to be included once challah_user is set up.
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

      # The default url where this user should be redirected to after logging in. Override
      # this method to change this behavior.
      def default_path
        '/'
      end

      def failed_authentication!
        self.increment!(:failed_auth_count)
      end

      # First name and last name together
      def name
        "#{first_name} #{last_name}".strip
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

        attributes_to_update.keys.each do |key|
          if protected_attributes.include?(key.to_s)
            attributes_to_update.delete(key)
          end
        end

        self.update_attributes(attributes_to_update)
      end

      # Is this user valid and ready for a user session?
      #
      # Override this method if you need to check for a particular configuration on each page request.
      def valid_session?
        self.active?
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

        # If the email was changed, hash it for use with gravatar and other services.
        #
        # For backwards compatibilty, this column may not always exist, so just ignore
        # this if the column doesn't exist.
        def check_email_hash
          if self.class.column_names.include?("email_hash")
            if email_changed?
              require 'digest/md5'
              self.email_hash = Digest::MD5.hexdigest(self.email.to_s.downcase.strip)
            end
          end
        end

        # Called before validations, if no username was provided but an email was, copy it over to the
        # username field.
        def sync_username
          if self.username.to_s.blank? and !self.email.to_s.blank?
            self.username = self.email
          end

          # Make sure username stored is always stripped of whitespace and downcased
          self.username = self.username.to_s.strip.downcase
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