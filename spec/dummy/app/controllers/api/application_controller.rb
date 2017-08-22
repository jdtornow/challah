unless defined?(API_BASE_CONTROLLER)
  API_BASE_CONTROLLER = ActionController::Base

  # For Rails 5.0+ use, API controller
  if defined?(ActionController::API) && !defined?(API_BASE_CONTROLLER)
    API_BASE_CONTROLLER = ActionController::API
  end
end

module Api
  class ApplicationController < API_BASE_CONTROLLER

    before_action :check_request_format
    before_action :require_authentication

    private

    def check_request_format
      unless params[:format] == "json"
        render json: {
          message: "Invalid request format. Only JSON requests are supported."
        }, status: :unsupported_media_type
      end
    end

    def require_authentication
      unless current_user
        render json: {
          message: "You must be authenticated to view this resource."
        }, status: :unauthorized
      end
    end

  end
end
