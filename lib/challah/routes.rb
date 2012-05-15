Rails.application.routes.draw do
  unless Challah.options[:skip_routes]
    match '/login',     :to => 'sessions#create',   :as => 'authenticate',  :via => :post
    match '/login',     :to => 'sessions#new',      :as => 'login',         :via => :get
    match '/logout',    :to => 'sessions#destroy',  :as => 'logout'

    match '/sign-in',   :to => 'sessions#create',   :as => 'authenticate',  :via => :post
    match '/sign-in',   :to => 'sessions#new',      :as => 'signin',        :via => :get
    match '/sign-out',  :to => 'sessions#destroy',  :as => 'signout'
  end

  # These are used for testing purposes only.
  if Rails.env.test?
    match '/challah/:action', :controller => 'challah/test/restrictions'
  end
end