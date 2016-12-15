Rails.application.routes.draw do

  root :to => "landing#index"

  get "home" => 'kiwis#show'

  get "health" => "kiwis#health"

  resources :kiwis

  resources :settings do
    collection do
      get 'personal'
      get 'social'
      get 'profile'
    end
  end

  resources :profiles, only: [:index]

  resources :accounts

  resources :products do
    collection do
      put 'buy'
      put 'reset'
    end
  end


  resources :identities, only: [:index] do
    collection do
      get 'sign_up'
      get 'login'
      get 'authorisation'
      put 'logout'
      get "test"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :kiwis
      resources :api_docs
    end
  end


end
