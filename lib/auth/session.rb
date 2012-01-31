module Auth
  class Session
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    attr_accessor :return_to, :ip, :user, :store
    attr_reader :params, :request, :persist
    
    cattr_accessor :storage_class
    
    def initialize(request = nil, params = {})
      @request = request
      @params = params || {}
      @store = self.class.storage_class.new(self)
    end
    
    # The path where a user will be redirected to upon login
    def default_path
      self.user ? self.user.default_path : '/'
    end
    
    def destroy
      self.store.destroy
      
      @valid = false
      @user = nil
    end
    
    def inspect
      "#<Session:0x#{object_id.to_s(16)} valid=#{valid?} store=#{self.store.inspect} user=#{user_id || 'nil'}>"
    end
   
    def persist?
      !!@persist
    end
    
    def read
      persistence_token, user_id = self.store.read      
      return false if persistence_token.nil? or user_id.nil?
      
      store_user = ::User.find_by_id(user_id)
      
      if store_user and store_user.active? and store_user.persistence_token == persistence_token
        self.user = store_user
        @valid = true
      end
      
      self
    end
    
    def save
      return false unless self.valid?
      
      if self.user
        self.store.save(self.user.persistence_token, user_id)
      end
    end
    
    # Id of the current user.
    def user_id
      @user_id ||= self.user ? self.user[:id] : nil
    end
    
    def username
      params[:username] || ""
    end
    
    # Returns true if this session has been authenticated and is ready to save.
    def valid?
      return @valid if @valid != nil
      return true if self.user and self.user.active?      
      authenticate!
    end
    
    # Allow for dynamic setting of instance variables.
    # also allows for variable? to see if it was provided
    def method_missing(sym, *args, &block)
      if @params.has_key?(sym)
        return @params[sym]
      elsif sym.to_s =~ /^[a-z0-9_]*=$/
        return @params[sym.to_s.sub(/^(.*?)=$/, '\1').to_sym] = args.shift
      elsif sym.to_s =~ /^[a-z0-9_]*\?$/
        return !!@params[sym.to_s.sub(/^(.*?)\?$/, '\1').to_sym]
      end
      
      super(sym, *args, &block)
    end
    
    class << self
      # Manually create a new Session
      def create(user_or_user_id)
        user_record = ::User === user_or_user_id ? user_or_user_id : ::User.find_by_id(user_or_user_id)
        
        session = Session.new()
        
        if user_record and user_record.active?
          session.user = user_record          
        end
        
        session
      end
      
      # Load any existing session from the session store
      def find(*args)
        session = Session.new(*args)
        session.read        
        session
      end
    end
    
    protected
      # Try and authenticate against the various auth techniques. If one
      # technique works, then just exist and make the session active.
      def authenticate!
        Auth.techniques.values.each do |klass|
          technique = klass.new(self)
          @user = technique.authenticate

          if @user
            @persist = technique.persist?
            break
          end
        end

        if @user
          @user.successful_authentication!(ip)
          return @valid = true
        end

        @valid = false
      end
  end
end