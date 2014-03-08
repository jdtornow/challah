module Challah
  module UserFindable
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      def active
        where(active: true)
      end

      # Find a user instance by username first, or email address if needed.
      # If no user is found matching, return nil
      def find_for_session(username_or_email)
        return nil if username_or_email.to_s.blank?

        result = nil

        if username_or_email.to_s.include?('@')
          result = where(email: username_or_email).first
        end

        if !result
          uid = username_or_email.to_s.downcase.strip

          authorization = self.authorization_model
          authorization = authorization.where(provider: :password, uid: uid)
          authorization = authorization.first

          if authorization
            result = authorization.user
          end
        end

        result
      end

      def inactive
        where.not(active: true)
      end
    end
  end
end