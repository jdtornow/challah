module Auth
  module Controller
    protected
      def logged_in?
        !!current_user
      end
      
      def current_user
        @current_user ||= current_user_session.user
      end
      
      def current_user_session
        @current_user_session ||= Auth::Session.find
      end
  end
end