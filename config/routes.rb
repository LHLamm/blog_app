Rails.application.routes.draw do
  root "articles#index"

  resources :articles, only: [ :index, :show, :new, :create, :edit, :update, :destroy ] do
    member do
      post :publish
      patch :autosave
    end
  end

  resource :dashboard, only: :show, controller: :dashboard

  namespace :api do
    namespace :v1 do
      resources :articles, only: [ :index ]
    end
  end

  resources :users, only: [ :show ]

  resource :registration, only: [ :new, :create ]

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :password_resets, only: [ :new, :create, :edit, :update ], param: :token

  get "verify_email/:token", to: "email_verifications#show", as: :verify_email
end
