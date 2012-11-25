module Challah
  module Authenticators
    class Password
      def self.match?(user, plain_password)
        if user.password_provider?
          crypted_password = user.password_provider[:token]
          return Encrypter.compare(crypted_password, plain_password)
        end

        false
      end
    end
  end
end