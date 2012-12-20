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

        attr_reader :password, :password_confirmation, :password_updated
        attr_accessible :provider_attributes

        # Validation
        ################################################################

        validates :email,           email_validation_hash
        validates :first_name,      presence: true
        validates :last_name,       presence: true

        validates_with Challah.options[:password_validator], force: false

        # Scoped Finders
        ################################################################

        scope :active,      where(active: true)
        scope :inactive,    where(active: false)

        # Callbacks
        ################################################################

        before_save :check_tokens
        after_save  :save_updated_providers
        after_save  :clear_cache
        before_destroy :clear_authorizations
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
        def save_updated_providers
          # Save password provider
          if @password_updated or @username_updated
            Challah.providers[:password].save(self)
            @password_updated = false
            @username_updated = false
            @password = nil
          end

          # Save any other providers
          Challah.custom_providers.each do |name, klass|
            custom_provider_attributes = provider_attributes[name]

            if custom_provider_attributes.respond_to?(:fetch)
              if klass.valid?(self)
                klass.save(self)
              end
            end
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

        def clear_authorizations
          authorizations.destroy_all
        end

        def clear_cache
          @providers = nil
        end
    end
  end
end