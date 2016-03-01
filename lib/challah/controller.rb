module Challah
  # These methods are added into ActionController::Base and are available in all
  # of your app's controllers.
  module Controller
    extend ActiveSupport::Concern

    included do
      extend ClassMethods
    end

    module ClassMethods
      # Restrict the current controller to only users that have authenticated. All actions
      # in the controller will be restricted unless otherwise stated. All normal options
      # for a before_action are observed.
      #
      # @example
      #   class YourController < ApplicationController
      #     restrict_to_authenticated
      #
      #     # ...
      #   end
      #
      # @example Restrict only the given actions
      #   class YourOtherController < ApplicationController
      #     restrict_to_authenticated :only => [ :create, :update, :destroy ]
      #
      #     # ...
      #   end
      #
      # @see Controller::InstanceMethods#signin_required signin_required
      def restrict_to_authenticated(options = {})
        before_action(options) do |controller|
          controller.send(:signin_required)
        end
      end

      # Alias for restrict_to_authenticated
      def signin_required(*args)
        restrict_to_authenticated(*args)
      end
      alias_method :login_required, :signin_required
    end

    protected

    # Is there currently a logged in user? Returns true if it is safe to use
    # the {#current_user current_user} method.
    #
    # @note This method is also available as a helper in your views.
    #
    # @see #current_user current_user
    #
    # @return [Boolean] Is there a user logged in?
    def current_user?
      !!current_user
    end

    # Alias for current_user?
    def signed_in?
      current_user?
    end
    alias_method :logged_in?, :signed_in?

    # The user that is currently logged into this session. If there is no
    # user logged in, nil will be returned.
    #
    # @note This method is also available as a helper in your views.
    #
    # @return [User, nil] The current authenticated user.
    def current_user
      @current_user ||= current_user_session.user
    end

    # The current authentication session, if one exists. A {Session} object will be
    # returned regardless of its valid status. If an invalid session is returned, the
    # {Session#user user} attribute will be nil.
    #
    # @return [Session] The current browser session.
    def current_user_session
      @current_user_session ||= Challah::Session.find(request, params, user_model)
    end

    # Restrict a controller to only authenticated users. If someone tries to access
    # a restricted action and is not logged in, they will be redirected to the
    # login page.
    #
    # This method is an alias for:
    #
    #   restrict_to_authenticated
    #
    # @example
    #   class YourController < ApplicationController
    #     before_action :login_required
    #
    #     # ...
    #   end
    #
    # @example Specifing certain actions.
    #   class YourOtherController < ApplicationController
    #     before_action :login_required, :only => [ :create, :update, :destroy ]
    #
    #     # ...
    #   end
    #
    # @see Controller::ClassMethods#restrict_to_authenticated restrict_to_authenticated
    def signin_required
      unless signed_in?
        session[:return_to] = request.url
        redirect_to signin_path and return
      end
    end
    alias_method :login_required, :signin_required

    def user_model
      @_challah_user_model ||= Challah.user
    end
  end
end
