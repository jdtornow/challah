module Challah
  class AuthenticatedRoutingConstraint
    attr_reader :request, :user_model, :block
    
    def initialize(user_model=nil, &block)
      @user_model = user_model || Challah.user
      @block = block
    end

    def matches?(request)
      @request = request
      authorized?
    end

    private

    def authorized?
      !!user && (block.nil? || block.call(user))
    end

    def session
      @session ||= Session.find(request, {}, user_model)
    end

    def user
      session.user
    end
  end
end
