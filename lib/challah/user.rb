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

      email_validation_hash = {
        presence: true,
        uniqueness: true
      }

      email_validator_key = Challah.options[:email_validator].to_s.underscore
      email_validation_hash[email_validator_key] = true

      class_eval do
        # Attributes
        ################################################################

        attr_reader :password, :password_confirmation

        # Validation
        ################################################################



        validates :email,           email_validation_hash

        validates :first_name,      presence: true
        validates :last_name,       presence: true
        validates :username,        presence: true,
                                    uniqueness: true

        validates_with Challah.options[:password_validator]

        # Scoped Finders
        ################################################################

        scope :active,      where(active: true)
        scope :inactive,    where(active: false)

        # Callbacks
        ################################################################

        before_save         :before_save_password
        before_save         :check_email_hash
        before_validation   :sync_username
      end

      Challah.include_user_plugins!
    end

    module ClassMethods
      # Find a user instance by username first, or email address if needed.
      # If no user is found matching, return nil
      def find_for_session(username_or_email)
        return nil if username_or_email.to_s.blank?

        result = nil

        result = self.where(username: username_or_email.to_s.strip.downcase).first

        unless result
          if username_or_email.to_s.include?('@')
            result = self.where(email: username_or_email).first
          end
        end

        result
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

          if Challah.authenticators[method]
            return Challah.authenticators[method].match?(self, *args)
          end

          false
        else
          self.authenticate(:password, args[0])
        end
      end

      def authenticate_with_password(plain_password)
        authenticate(:password, plain_password)
      end

      def authenticate_with_api_key(api_key)
        authenticate(:api_key, api_key)
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

      # Set the password and password_confirmation in one shortcut method.
      def password!(new_password)
        self.password = new_password
        self.password_confirmation = new_password
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

      # Was the password updated
      def password_changed?
        !!@password
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
            self.crypted_password = Encrypter.encrypt(@password)

            @password_updated = false
            @password = nil
          end

          self.persistence_token = Random.token(125) if self.persistence_token.to_s.blank?
          self.api_key = Random.token(50) if self.api_key.to_s.blank?
        end

        # If the email was changed, hash it for use with gravatar and other services.
        #
        # For backwards compatibilty, this column may not always exist, so just ignore
        # this if the column doesn't exist.
        def check_email_hash
          if self.class.column_names.include?("email_hash")
            if email_changed?
              self.email_hash = Encrypter.md5(email.to_s.downcase.strip)
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
    end
  end
end