module Challah::User
  module Authentication
    # Generic authentication method. By default, this just checks to see if the password
    # given matches this user. You can also pass in the first parameter as the method
    # to use for a different type of authentication.
    def authenticate(*args)
      return false unless active?

      if args.length > 1
        method = args.shift

        if Challah.authenticators[method]
          return Challah.authenticators[method].match?(self, *args)
        end

        false
      else
        self.authenticate(:password, args[0])
      end
    end

    def authenticate_with_password(plain_password)
      authenticate(:password, plain_password)
    end

    def authenticate_with_api_key(api_key)
      authenticate(:api_key, api_key)
    end

    def failed_authentication!
      self.increment!(:failed_auth_count)
    end

    # Called when a +Session+ validation is successful, and this user has
    # been authenticated.
    def successful_authentication!(ip_address = nil)
      self.last_session_at = Time.now
      self.last_session_ip = ip_address
      self.save
      self.increment!(:session_count, 1)
    end
  end
end