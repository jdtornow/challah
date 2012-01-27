module Auth
  class Session
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    attr_accessor :return_to, :ip
    attr_reader :params, :request, :user    
    attr_accessor :username, :password
    
    def initialize(request = nil, params = nil)
      @request = request
      @params = params
      
      # If params was given and is hash, grab username and password if they are present
      if @params and params.respond_to?(:key?)
        self.username = params[:username] if params.has_key?(:username)
        self.password = params[:password] if params.has_key?(:password)
      end
    end
    
    # Shouldn't be able to access the password outside of this model
    def password
      nil
    end
    
    # Was a password provided
    def password?
      !@password.to_s.blank?
    end
    
    # Was a username provided
    def username?
      !@username.to_s.blank?
    end
    
    # Returns true if this session has been authenticated and is ready to save.
    def valid?
      return @valid if @valid != nil
      return true if user and user.active?
      
      if username?
        user = User.find_for_session(self.username)
        
        if user.active?
          if password?
            if user.authenticate(:password, @password)
              @valid = true
              user.successful_authentication!(self.ip)
              @user = user              
              return true
            end
          end
        end
        
        user.failed_authentication!
      end
      
      false
    end
  end
end