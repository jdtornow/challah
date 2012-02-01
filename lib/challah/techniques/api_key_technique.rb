module Challah
  class ApiKeyTechnique
    def initialize(session)
      @key = session.api_key? ? session.api_key : nil   
    end
    
    def authenticate
      unless @key.to_s.blank?
        user = ::User.find_by_api_key(@key)
        
        if user and user.active?
          return user
        end
      end
      
      nil
    end
    
    def persist?
      false
    end
  end
end