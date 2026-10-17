Rails.application.routes.draw do
  #define nuestras URL existentes y a que accion mandan cada cosita
  #el app/controllers/exchange_request_controller.rb es el codigo que se ejecuta cuando alguien entra
  #a alguna de las URL que dejamos aqui
  devise_for :users

  resources :books, only: [:show, :new, :create, :edit, :update, :destroy] do
    resources :exchange_requests, only: [:new, :create]
  end

  resources :exchange_requests, only: [:index] do
    member do #'member' crea son para la solicitud en particular tal que la url lleva a su :id
      patch :accept #URL: /exchange_request/id/accept VA A exchange_request#accept
      #donde el helper seria accept_exchange_request_path(request)
      patch :reject
    end
  end

  resources :users, only: [:index, :show]

  resources :wishlist_items, only: [:index, :create, :edit, :update, :destroy]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "welcome#index"
end

