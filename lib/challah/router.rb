module ActionDispatch::Routing
  ##
  # This provides helper methods for use in routes.rb
  class Mapper

    ##
    # This will constrain a set of routes based on the authentication:
    #
    # If no user is present the nested routes will not be available
    #
    # If the user is present, but the optionally provided block does not return
    # true, the routes will not be available
    def authenticate(user_model=nil, block=nil)
      constraint = lambda do |request|
        session = Challah::Session.find(request, {}, user_model)
        !!session.user && (block.nil? || block.call(session.user))
      end

      constraints(constraint) do
        yield
      end
    end

  end
end
