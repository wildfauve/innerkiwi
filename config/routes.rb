Rails.application.routes.draw do
  
  root :to => "landing#index"
  
  get "home" => 'kiwis#show'
  
  resources :kiwis
  
  resources :settings
  
  resources :accounts
  
  resources :identities, only: [:index] do
    collection do
      get 'sign_up'
      get 'login'
      get 'authorisation'
      put 'logout'
    end
  end
  
end
