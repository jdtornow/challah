module Challah
  module Controller
    protected
      def current_user?
        !!current_user
      end
      alias_method :logged_in?, :current_user?
      
      def current_user
        @current_user ||= current_user_session.user
      end
      
      def current_user_session
        @current_user_session ||= Challah::Session.find(request)
      end
      
      # Restrict a controller to only authenticated users. If someone tries to access
      # a restricted action and is not logged in, they will be redirected to the 
      # login page.
      #
      # @example
      #   class YourController < ApplicationController
      #     before_filter :login_required
      #
      # @example Specifing certain actions.
      #   class YourOtherController < ApplicationController
      #     before_filter :login_required, :only => [ :create, :update, :destroy ]
      #     
      def login_required
        unless logged_in?
          session[:return_to] = request.url
          redirect_to login_path and return
        end
      end
  end
end