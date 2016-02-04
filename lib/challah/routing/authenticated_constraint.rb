module Challah
  class AuthenticatedRoutingConstraint
    attr_reader :request, :user_model, :block

    def initialize(user_model=nil)
      @user_model = user_model || Challah.user
      @block = Proc.new if block_given?
    end

    def matches?(request)
      user = Session.find(request, {}, user_model).user
      !!user && (block.nil? || block.call(user))
    end

    def self.matches?(request)
      !!Session.find(request, {}, Challah.user).user
    end
  end
end
