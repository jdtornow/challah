module Challah::User
  module Finders
    # Find a user instance by username first, or email address if needed.
    # If no user is found matching, return nil
    def find_for_session(username_or_email)
      return nil if username_or_email.to_s.blank?

      result = nil

      if username_or_email.to_s.include?('@')
        result = where(email: username_or_email).first
      end

      if !result
        authorization = ::Authorization.where(provider: :password, uid: username_or_email.to_s.downcase.strip).first

        if authorization
          result = authorization.user
        end
      end

      result
    end
  end
end