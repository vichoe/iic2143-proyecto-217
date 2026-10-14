Rails.application.routes.draw do
  devise_for :users

  resources :books, only: [:show, :new, :create, :edit, :update, :destroy] do
    resources :exchange_requests, only: [:new, :create]
  end
  resources :exchange_requests, only: [:index]

  resources :users, only: [:index, :show]

  resources :wishlist_items, only: [:index, :create, :edit, :update, :destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "welcome#index"
end