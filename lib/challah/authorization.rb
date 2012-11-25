module Challah
  module Authorization
    def challah_authorization
      unless included_modules.include?(InstanceMethods)
        include InstanceMethods
        extend ClassMethods
      end
    end

    module InstanceMethods
      def user
        return nil unless self.user_id
        @user ||= ::User.where(id: self.user_id).first
      end
    end

    module ClassMethods
      # Remove an authorization
      def del(options = {})
        provider  = options.fetch(:provider)
        user_id   = options.fetch(:user_id)

        where(provider: provider, user_id: user_id).delete_all
      end

      # Create a new authorization record for the given user
      def set(options = {})
        provider  = options.fetch(:provider)
        user_id   = options.fetch(:user_id)
        uid       = options.fetch(:uid)
        token     = options.fetch(:token)

        del(options)

        create!({
          provider: provider,
          user_id:  user_id,
          uid:      uid,
          token:    token
        }, without_protection: true)
      end
    end
  end
end