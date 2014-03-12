module Challah
  # Store session data in a cookie, but use the user's user_agent and ip address
  # in the cookie verification, for additional security.
  #
  # This method will force the user to log in slightly more often, as user agents
  # and IP addresses change.
  #
  # To use a different storage method for persisting a session, just create
  # a new class that responds to +read+, +save+ and +destroy+
  #
  class CookieStore < SimpleCookieStore
    def inspect
      "#<CookieStore:0x#{object_id.to_s(16)} valid=#{existing?}>"
    end

    protected

    def validation_cookie_value(value = nil)
      value = session_cookie_value unless value
      Encrypter.md5(value, request.user_agent, request.remote_ip)
    end
  end
end
