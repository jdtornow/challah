require 'challah/techniques/api_key_technique'
require 'challah/techniques/password_technique'

module Challah
  # Techniques are used to allow different methods of authentication. By default, there are
  # two techniques included: Password and ApiKey.
  #
  # Techniques are just regular Ruby classes, that respond to several methods. At a minimum,
  # any new techniques should contain an +authenticate+ and +persist?+ method. Authenticate
  # will return a user if the authentication was successful, and persist? returns true if
  # this session should be persisted using cookies. If persist? is false, then no cookies will
  # be added, and the user will only be logged in for a single request.
  #
  # Sample technique file that lets anyone in with the shared password:
  #
  #     class SharedPasswordTechnique
  #       def initialize(session)
  #         @session = session
  #       end
  #
  #       # Authenticate this user, return a User instance if valid, nil otherwise
  #       def authenticate
  #         # was params[:secret] provided to the request
  #         if @session.secret?
  #           # does the params[:secret] value match our shared password?
  #           if @session.secret == 'let-me-in'
  #             # if the secret was correct, grab the username from params, and load the user
  #             user = User.find_for_session(@session.username)
  #             return user
  #           end
  #         end
  #
  #         nil
  #       end
  #
  #       # Keep this user logged in?
  #       def persist?
  #         true
  #       end
  #     end
  #
  # To add a new technique, just register it using:
  #
  #     Challah.register_technique(:shared_password, SharedPasswordTechnique)
  #
  # The first parameter is just a key for that technique, the second p param is the class name to use.
  #
  # You can remove an existing technique by calling +remove_technique+:
  #
  #     Challah.remove_technique(:shared_password)
  #
  # This is useful for removing the techniques included by default +PasswordTechnique+ and
  # +ApiKeyTechnique+.
  #
  module Techniques
    # Register a new technique class. Pass in a name as an identifier, and the class to use
    # when attempting to authenticate.
    def register_technique(name, klass)
      @techniques[name] = klass
    end

    # Remove an existing technique class. Pass in the identifier used in +register_techinque+
    def remove_technique(name)
      @techniques.delete(name)
    end

    # Get the list of all techniques that have been registered.
    def techniques
      @techniques.dup
    end
  end
end
