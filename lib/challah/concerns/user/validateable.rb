module Challah
  module UserValidateable
    extend ActiveSupport::Concern

    included do
      email_validation_hash = {
        presence: true,
        uniqueness: true
      }

      email_validator_key = Challah.options[:email_validator].to_s.underscore
      email_validation_hash[email_validator_key] = true

      validates :email,           email_validation_hash
      validates :first_name,      presence: true
      validates :last_name,       presence: true

      validates_with Challah.options[:password_validator], force: false
    end
  end
end