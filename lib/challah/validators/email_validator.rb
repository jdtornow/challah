module Challah
  # Used to validate reasonably-email-looking strings.
  #
  # @example Usage
  #     class User < ActiveRecord::Base
  #       validates :email, :presence => true, :email => true
  #     end
  class EmailValidator < ActiveModel::EachValidator
    # Called automatically by ActiveModel validation..
    def validate_each(record, attribute, value)
      unless value =~ EmailValidator.pattern
        record.errors.add(attribute, options[:message] || :invalid_email)
      end
    end

    # A reasonable-email-looking regexp pattern
    def self.pattern
      /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,}\z/
    end
  end
end
