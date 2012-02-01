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
  end
end