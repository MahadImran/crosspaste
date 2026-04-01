Rails.application.routes.draw do
  mount ActionCable.server => "/cable"

  get "up" => "rails/health#show", as: :rails_health_check
  root "rooms#index"

  post "join", to: "rooms#join", as: :join_room

  resources :rooms, only: [ :create, :show, :update, :destroy ], param: :code do
    post :clear, on: :member
  end
end
