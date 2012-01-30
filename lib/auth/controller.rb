module Auth
  module Controller
    protected
      def signed_in?
        !!current_user
      end
      alias_method :current_user?, :signed_in?
      
      def current_user
        @current_user ||= current_user_session.user
      end
      
      def current_user_session
        @current_user_session ||= Auth::Session.find(request)
      end
  end
end