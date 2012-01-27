require 'auth/techniques/api_key_technique'
require 'auth/techniques/password_technique'

module Auth
  module Techniques
    def register_technique(name, klass)
      @techniques[name] = klass
    end
    
    def techniques
      @techniques.dup
    end
  end
end