Rails.application.routes.draw do

  # Testing routes
  get "/challah", to: "restrictions#index", as: :test_index
  get "/challah/show", to: "restrictions#show", as: :test_show
  get "/challah/edit", to: "restrictions#edit", as: :test_edit
  get "/challah/blah", to: "restrictions#blah", as: :test_blah

  namespace :api, defaults: { format: "json" } do
    get "/sample", to: "sample#index", as: :sample
  end

end
