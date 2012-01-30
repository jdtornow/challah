module Auth
  class Session
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    attr_accessor :return_to, :ip
    attr_reader :params, :request, :user, :persist
    
    def initialize(request = nil, params = {})
      @request = request
      @params = params
    end
    
    # Returns true if this session has been authenticated and is ready to save.
    def valid?
      return @valid if @valid != nil
      return true if user and user.active?
      
      Auth.techniques.values.each do |klass|
        technique = klass.new(self)
        @user = technique.authenticate
        
        if @user
          @persist = technique.persist?
          break
        end
      end
      
      if user
        user.successful_authentication!(self.ip)
        return @valid = true
      end
      
      false
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
  end
end