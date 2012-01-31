module Auth
  # A base class for storing session data in a browser cookie.
  # 
  # To use a different storage method for persisting a session, just create
  # a new class that responds to +read+, +save+ and +destroy+
  class CookieStore
    cattr_accessor :prefix
    
    def initialize(session)
      @session = session
    end
    
    def destroy
      clear
    end
    
    def read
      if cookies[session_cookie_name]
        return cookies[session_cookie_name].to_s.split(joiner)
      end
        
      nil
    end
    
    def save(token, user_id)
      @token = token
      @user_id = user_id
      
      write_cookies!
    end
    
    private
      def clear
        cookies.delete(session_cookie_name, :domain => domain)
        cookies.delete(validation_cookie_name, :domain => domain)
      end
    
      def cookies
        request.cookie_jar
      end
      
      def domain
        request.session_options[:domain]
      end
      
      def expiration
        @expiration ||= 1.month.from_now
      end
      
      def joiner
        '@'
      end
      
      def prefix
        @prefix ||= self.class.prefix
      end
      
      def request
        raise "No Request Provided" unless @session and @session.request
        
        @session.request
      end
    
      def session_cookie_name
        "#{prefix}-s"
      end
      
      def session_cookie_value
        @session_cookie_value ||= "#@token#{joiner}#@user_id"
      end
      
      def validation_cookie_name
        "#{prefix}-v"
      end
      
      def validation_cookie_value
        Encrypter.md5(session_cookie_value, request.user_agent, request.remote_ip)
      end
      
      def write_cookies!
        cookies[session_cookie_name] = {
          :value => session_cookie_value,
          :expires => expiration,
          :secure => false,
          :httponly => true,
          :domain => domain
        }
        
        cookies[validation_cookie_name] = {
          :value => validation_cookie_value,
          :expires => expiration,
          :secure => false,
          :httponly => true,
          :domain => domain
        }
      end
  end
end