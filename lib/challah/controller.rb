module Challah
  # These methods are added into ActionController::Base and are available in all
  # of your app's controllers.
  module Controller
    # @private
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      # Restrict the current controller to only users that have authenticated. All actions
      # in the controller will be restricted unless otherwise stated. All normal options
      # for a before_filter are observed.
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
        before_filter(options) do |controller|
          controller.send(:signin_required)
        end
      end

      # Alias for restrict_to_authenticated
      def signin_required(*args)
        restrict_to_authenticated(*args)
      end
      alias_method :login_required, :signin_required

      # Restrict the current controller to the given permission key. All actions in the
      # controller will be restricted unless otherwise stated. All normal options
      # for a before_filter are observed.
      #
      # If the current user does not have the given permission key, they are shown the
      # access denied message.
      #
      # @example
      #   class YourController < ApplicationController
      #     restrict_to_permission :manage_users
      #
      #     # ...
      #   end
      #
      # @example Restrict only the given actions
      #   class YourOtherController < ApplicationController
      #     restrict_to_permission :manage_users, :only => [ :create, :update, :destroy ]
      #
      #     # ...
      #   end
      #
      # @param [String, Symbol] permission_key The permission to restrict action(s) to.
      def restrict_to_permission(permission_key, options = {})
        before_filter(options) do |controller|
          unless controller.send(:has, permission_key)
            access_denied!
          end
        end
      end
      alias_method :permission_required, :restrict_to_permission
    end

    module InstanceMethods
      protected
        # Stop execution of the current action and display the access denied message.
        #
        # If the user is not logged in, they are redirected to the login screen.
        #
        # By default the built-in access denied message is displayed, but you can display a different
        # message by setting the following option in an initializer:
        #
        #   Challah.options[:access_denied_view] = 'controller/denied-view-name'
        #
        # A status code of :unauthorized (401) will be returned.
        #
        # Override this method if you'd like something different to happen when your users
        # get an access denied notification.
        def access_denied!
          if current_user?
            render :template => Challah.options[:access_denied_view], :status => :unauthorized and return
          else
            session[:return_to] = request.url
            redirect_to signin_path and return
          end
        end

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
          @current_user_session ||= Challah::Session.find(request, params)
        end

        # Checks the current user to see if they have the given permission key. If there is
        # not a user currently logged in, false is always returned.
        #
        # @note This method is also available as a helper in your views.
        #
        # @example
        #   class SecureController < ApplicationController
        #     def index
        #       # Redirect anyone that doesn't have :see_secure_stuff permission.
        #       unless has(:see_secure_stuff)
        #         redirect_to root_path and return
        #       end
        #     end
        #   end
        #
        # @see AuthableUser::InstanceMethods#has User#has
        def has(permission_key)
          current_user and current_user.has(permission_key)
        end
        alias_method :permission?, :has

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
        #     before_filter :login_required
        #
        #     # ...
        #   end
        #
        # @example Specifing certain actions.
        #   class YourOtherController < ApplicationController
        #     before_filter :login_required, :only => [ :create, :update, :destroy ]
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
    end
  end
end