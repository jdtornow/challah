module Challah
  # Allows authentication with a token URL parameter or X-Auth-Token header.
  # Useful for API-based authentication.
  class TokenTechnique

    attr_accessor :user_model

    def initialize(session)
      if session.request && session.request.headers[header_key]
        @token = session.request.headers[header_key].to_s
      else
        @token = session.params[:token].to_s
      end
    end

    def authenticate
      # Token authorization functionality is only enabled with the :token_enabled option.
      # This is turned off by default and must be manually enabled for security reasons.
      return nil unless Challah.options[:token_enabled]

      return nil unless token.present?

      if user = user_model.where(api_key: token).first
        if user.valid_session?
          return user
        end
      end

      nil
    end

    def header_key
      Challah.options[:token_header] || "X-Auth-Token"
    end

    def persist?
      false
    end

    def user_model
      @user_model ||= Challah.user
    end

    private

    attr_reader :token

  end
end
