module Challah
  module UserAttributeable
    extend ActiveSupport::Concern

    included do
      attr_reader :password
      attr_reader :password_confirmation
      attr_reader :password_updated

      enum status: %w( active inactive )

      before_save :ensure_user_tokens
      before_validation :normalize_user_email
    end

    # Fallback to pre-enum active column
    def active=(enabled)
      self.status = (!!enabled ? :active : :inactive)
    end

    def active
      active?
    end

    # First name and last name together
    def name
      "#{ first_name } #{ last_name }".strip
    end

    # shortened name, just includes the first name and last initial
    def small_name
      "#{ first_name.to_s.titleize } #{ last_name.to_s.first.upcase }."
    end

    # Is this user valid and ready for a user session?
    #
    # Override this method if you need to check for a particular configuration on each page request.
    def valid_session?
      active?
    end

    protected

    # Ensure that all system-generated columns aren't blank on each save
    def ensure_user_tokens
      ensure_api_key_presence
      ensure_email_hash_presence
      ensure_persistence_token_presence
    end

    # Store a random seed for this user's api key
    def ensure_api_key_presence
      if respond_to?("api_key=")
        if self.api_key.to_s.blank?
          self.api_key = Random.token(50)
        end
      end
    end

    # Store a hashed email if the column exists
    def ensure_email_hash_presence
      if respond_to?("email_hash=")
        if email_changed?
          self.email_hash = Encrypter.md5(email.to_s.downcase.strip)
        end
      end
    end

    # Store a random token to identify user in persisted objects
    def ensure_persistence_token_presence
      if respond_to?("persistence_token=")
        if self.persistence_token.to_s.blank?
          self.persistence_token = Random.token(125)
        end
      end
    end

    # Downcase email and strip if of whitespace
    # Ex: "   HELLO@example.com   " => "hello@example.com"
    def normalize_user_email
      self.email = self.email.to_s.downcase.strip
    end
  end
end
