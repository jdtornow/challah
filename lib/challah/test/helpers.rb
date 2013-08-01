module Challah
  module Test
    module Helpers
      # Sign the given user instance in
      def signin_as(user)
        Challah::Session.create!(user)
      end
      alias_method :login_as, :signin_as

      # Sign the given user instance out
      def signout
        Challah::Session.destroy
      end
      alias_method :logout, :signout
    end
  end
end


