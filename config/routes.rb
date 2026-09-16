Rails.application.routes.draw do
  root "trips#index"

  resources :trips, only: :index

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "bookings/confirm", to: "bookings#confirm", as: :confirm_booking
  post "bookings/confirm", to: "bookings#confirm"

  resources :bookings, only: [ :index, :show, :destroy ] do
    member do
      post :cancel
    end
  end

  post "bookings/create", to: "bookings#create", as: :create_booking

  get "up" => "rails/health#show", as: :rails_health_check
end
