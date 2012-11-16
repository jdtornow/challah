require 'challah/user/attributes'
require 'challah/user/authentication'
require 'challah/user/finders'

module Challah
  module User
    def challah_user
      unless included_modules.include?(InstanceMethods)
        include Attributes
        include Authentication
        include InstanceMethods
        extend Finders
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

    # Instance methods to be included once challah_user is set up.
    module InstanceMethods
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