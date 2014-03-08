module Challah
  module UserAuthorizable
    extend ActiveSupport::Concern

    included do
      extend ClassMethods

      before_destroy :clear_authorizations_before_destroy
    end

    protected

    def authorizations
      return [] if new_record?
      self.class.authorization_model.where(user_id: self.id)
    end

    def clear_authorizations_before_destroy
      authorizations.destroy_all
    end

    module ClassMethods
      def authorizations_table_name
        @authorizations_table_name ||= authorization_model.table_name
      end

      def authorization_model
        @authorization_model ||= ::Authorization
      end
    end
  end
end