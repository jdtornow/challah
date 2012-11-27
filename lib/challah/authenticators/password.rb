module Challah
  module Authenticators
    class Password
      def self.match?(user, provider, plain_password)
        if provider
          crypted_password = provider.fetch(:token)
          return Encrypter.compare(crypted_password, plain_password)
        end

        false
      end
    end
  end
end