module Challah
  module UserFindable
    extend ActiveSupport::Concern

    module ClassMethods

      # Find a user instance by username first, or email address if needed.
      # If no user is found matching, return nil
      def find_for_session(username_or_email)
        return if username_or_email.to_s.blank?

        username_or_email = username_or_email.downcase.strip
        find_by_email(username_or_email) || find_by_authorization(username_or_email)
      end

      protected

      def find_by_authorization(uid)
        authorization = self.authorization_model
        result = authorization.where(provider: :password, uid: uid).first
        if result
          result.user
        end
      end

      def find_by_email(email)
        return unless email.include?('@')
        where(email: email).first
      end
    end
  end
end
