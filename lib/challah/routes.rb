Rails.application.routes.draw do
  unless Challah.options[:skip_routes]
    match '/login' => 'sessions#create', :as => 'authenticate', :via => :post
    match '/login' => 'sessions#new', :as => 'login', :via => :get
    match '/logout' => 'sessions#destroy', :as => 'logout'
  end
  
  if Rails.env.test?
    # These are used for testing purposes only.
    match '/_ch_/:action', :controller => 'challah/test/restrictions'
  end
end