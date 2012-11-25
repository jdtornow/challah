require 'challah/user/attributes'
require 'challah/user/authentication'
require 'challah/user/finders'
require 'challah/user/providers'
require 'challah/user/password'

module Challah
  module User
    def challah_user
      unless included_modules.include?(InstanceMethods)
        include Attributes
        include Authentication
        include InstanceMethods
        include Providers
        include Password
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

        validates_with Challah.options[:password_validator]

        # Scoped Finders
        ################################################################

        scope :active,      where(active: true)
        scope :inactive,    where(active: false)

        # Callbacks
        ################################################################

        before_save :check_tokens
        after_save  :check_for_password_updates
      end

      Challah.include_user_plugins!
    end

    # Instance methods to be included once challah_user is set up.
    module InstanceMethods
      def method_missing(method, *args)
        method_name = method.to_s

        if method_name =~ /^([a-z]*)_provider\?$/
          return provider?($1)
        elsif method_name =~ /^([a-z]*)_provider$/
          return provider($1)
        end

        super
      end

      protected
        # If password or username was changed, update the authorization record
        def check_for_password_updates
          if @password_updated or @username_updated
            Challah::PasswordProvider.set({
              uid: username,
              token: @password,
              user_id: self.id
            })

            @password_updated = false
            @username_updated = false
            @password = nil
          end
        end

        # Before a record is saved, make sure all tokens are set properly
        def check_tokens
          if self.persistence_token.to_s.blank?
            self.persistence_token = Random.token(125)
          end

          if self.api_key.to_s.blank?
            self.api_key = Random.token(50)
          end

          # Store a hashed email if the column exists
          if respond_to?("email_hash=")
            if email_changed?
              self.email_hash = Encrypter.md5(email.to_s.downcase.strip)
            end
          end
        end
    end
  end
end