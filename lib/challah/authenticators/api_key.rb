module Challah
  module Authenticators
    class ApiKey
      def self.match?(user, provider, api_key)
        user.api_key ==  api_key.to_s.strip
      end
    end
  end
end