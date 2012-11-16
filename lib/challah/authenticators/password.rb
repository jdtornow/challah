module Challah
  module Authenticators
    class Password
      def self.match?(user, plain_password)
        Encrypter.compare(user.crypted_password, plain_password)
      end
    end
  end
end