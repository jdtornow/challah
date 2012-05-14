module Challah
  # Allows authentication with an api_key URL parameter.
  class ApiKeyTechnique
    def initialize(session)
      @key = session.key? ? session.key : nil
    end

    def authenticate
      # Api key functionality is only enabled with the :api_key_enabled option. This is turned
      # off by default and must be manually enabled for security reasons.
      return nil unless Challah.options[:api_key_enabled]

      unless @key.to_s.blank?
        user = ::User.find_by_api_key(@key)

        if user and user.active?
          return user
        end
      end

      nil
    end

    def persist?
      false
    end
  end
end