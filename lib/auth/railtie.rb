module Auth
  if defined? Rails::Engine
    require 'rails'
    
    class Engine < Rails::Engine
      initializer 'auth.setup_active_record' do
        ActiveSupport.on_load :active_record do
          Auth::Railtie.setup
        end
      end
    end
  end
  
  class Railtie
    def self.setup
      
    end
  end
end