module Challah
  if defined? Rails::Engine
    require 'rails'
    
    class Engine < Rails::Engine
      # Load up the routes first before your application specific routes, so these can be 
      # overridden if needed.
      initializer 'challah.router' do |app|
        raise 'hell'
        app.routes_reloader.paths.insert(0, File.expand_path(File.dirname(__FILE__), 'routes.rb'))
      end
    end
  end
end