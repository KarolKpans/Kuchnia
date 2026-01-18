Rails.application.routes.draw do
  root "home#index"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :users, only: [:new, :create]

  get '/kategorie/:slug', to: 'categories#show', as: :category_recipes

  get "moje-przepisy", to: "recipes#my_recipes", as: :my_recipes

  resources :recipes do
    member do
      post :rate
      post   :create_comment
      patch  :update_comment
      delete :destroy_comment
      get    :edit_comment_frame
    end
  end
  namespace :admin do
    resources :users, only: [:index, :destroy]
  end
end