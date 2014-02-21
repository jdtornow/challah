Rails.application.routes.draw do
  unless Challah.options[:skip_routes]
    post '/sign-in',    to: 'sessions#create',    as: 'authenticate'
    get '/sign-in',     to: 'sessions#new',       as: 'signin'
    get '/sign-out',    to: 'sessions#destroy',   as: 'signout'

    post '/login',      to: 'sessions#create',    as: 'submit_login'
    get '/login',       to: 'sessions#new',       as: 'login'
    get '/logout',      to: 'sessions#destroy',   as: 'logout'
  end
end
