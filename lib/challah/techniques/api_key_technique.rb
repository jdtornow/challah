module Challah
  # Allows authentication with an api_key URL parameter.
  class ApiKeyTechnique

    attr_accessor :user_model

    def initialize(session)
      @key        = session.key? ? session.key : nil
    end

    def authenticate
      # Api key functionality is only enabled with the :api_key_enabled option. This is turned
      # off by default and must be manually enabled for security reasons.
      return nil unless Challah.options[:api_key_enabled]

      unless @key.to_s.blank?
        user = user_model.find_by_api_key(@key)

        if user and user.active?
          return user
        end
      end

      nil
    end

    def persist?
      false
    end

    def user_model
      @user_model ||= Challah.user
    end

  end
end