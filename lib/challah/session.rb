module Challah
  class Session
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_accessor :return_to, :ip, :user, :store, :persist
    attr_reader :params, :request

    def initialize(request = nil, params = {})
      @request = request
      @params = params || {}
      @store = Challah.options[:storage_class].new(self)
    end

    def destroy
      self.store.destroy

      @valid = false
      @user = nil
    end

    def find
      self.read

      # If no session was found, try and authenticate
      unless valid?
        self.authenticate!
      end

      self
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

      store_user = ::User.unscoped.where(id: user_id).first

      if store_user and store_user.active? and store_user.persistence_token == persistence_token
        if store_user.valid_session?
          self.user = store_user
          @valid = true
        end
      end

      self
    end

    def save
      return false unless valid?

      if self.user and persist?
        self.store.save(self.user.persistence_token, user_id)
        return true
      end

      false
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
      def create(user_or_user_id, request = nil, params = nil)
        user_record = ::User === user_or_user_id ? user_or_user_id : ::User.find_by_id(user_or_user_id)

        session = Session.new(request, params)

        if user_record and user_record.active?
          session.user = user_record
          session.persist = true
        end

        session
      end

      # Manually create a session, and save it.
      def create!(user_or_user_id, request = nil, params = nil)
        session = create(user_or_user_id, request, params)
        session.save
        session
      end

      # Clear out any existing sessions
      def destroy
        session = Session.find
        session.destroy if session
        session
      end

      # Load any existing session from the session store
      def find(*args)
        session = Session.new(*args)
        session.find
        session
      end
    end

    protected
      # Try and authenticate against the various auth techniques. If one
      # technique works, then just exist and make the session active.
      def authenticate!
        Challah.techniques.values.each do |klass|
          technique = klass.new(self)
          @user = technique.authenticate

          if @user
            @persist = technique.respond_to?(:persist?) ? technique.persist? : false
            break
          end
        end

        if @user
          # Only update user record if persistence is on for the technique.
          # Otherwise this builds up quick (one session for each API call)
          if @persist
            @user.successful_authentication!(ip)
          end

          return @valid = true
        end

        @valid = false
      end
  end
end