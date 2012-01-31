Rails.application.routes.draw do  
  match '/_', :to => 'session#index', :as => 'base'
  
  match '/sign-in' => 'auth/sessions#create', :as => 'authenticate', :via => :post
  match '/sign-in' => 'auth/sessions#new', :as => 'signin', :via => :get
  match '/sign-out' => 'auth/sessions#destroy', :as => 'signout'
end