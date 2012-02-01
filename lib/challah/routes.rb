Rails.application.routes.draw do  
  match '/_', :to => 'session#index', :as => 'base'
  
  match '/login' => 'challah/sessions#create', :as => 'authenticate', :via => :post
  match '/login' => 'challah/sessions#new', :as => 'login', :via => :get
  match '/logout' => 'challah/sessions#destroy', :as => 'logout'
  
  # These are used for testing purposes only.
  match '/__challah__/:action', :controller => 'challah/test/restrictions'
end