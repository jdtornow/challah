Rails.application.routes.draw do  
  match '/_', :to => 'session#index', :as => 'base'
  
  match '/sign-in' => 'challah/sessions#create', :as => 'challahenticate', :via => :post
  match '/sign-in' => 'challah/sessions#new', :as => 'signin', :via => :get
  match '/sign-out' => 'challah/sessions#destroy', :as => 'signout'
end