module Challah
  module Authorizeable
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    def user
      return nil unless self.user_id
      @user ||= self.class.user_model.where(id: self.user_id).first
    end

    module ClassMethods
      def hashable_attributes
        protected_attributes = %w( user_id provider last_session_at last_session_ip session_count created_at updated_at )
        @hashable_attributes ||= self.columns.map(&:name) - protected_attributes
      end

      # Remove an authorization
      def del(options = {})
        provider  = options.fetch(:provider)
        user_id   = options.fetch(:user_id)

        where(provider: provider, user_id: user_id).delete_all
      end

      # Grab the user/provider record
      def get(options = {})
        provider  = options.fetch(:provider)
        user_id   = options.fetch(:user_id)

        where(provider: provider, user_id: user_id).first
      end

      # Create a new authorization record for the given user
      def set(options = {})
        provider    = options.delete(:provider)
        user_id     = options.delete(:user_id).to_i
        uid         = options.delete(:uid)
        token       = options.delete(:token)
        expires_at  = options.delete(:expires_at) || nil

        del(provider: provider, user_id: user_id)

        record = self.new()
        record.provider = provider
        record.user_id = user_id
        record.uid = uid
        record.token = token
        record.expires_at = expires_at

        record.attributes = options if options.any?

        record.save!
        record
      end

      def users_table_name
        @users_table_name ||= user_model.table_name
      end

      def user_model
        @user_model ||= Challah.user
      end
    end
  end
end
