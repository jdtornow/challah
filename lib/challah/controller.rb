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
      
      # Restrict a controller to only authenticated users.
      #
      # @example
      #   class YourController < ApplicationController
      #     before_filter :login_required
      #     ...
      #
      # @example Specifing certain actions.
      #   class YourOtherController < ApplicationController
      #     before_filter :login_required, :only => [ :create, :update, :destroy ]
      #     ...
      def login_required
        
      end
  end
end