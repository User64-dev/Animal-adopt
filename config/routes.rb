Rails.application.routes.draw do
  resources :users
  
  # Animal routes
  resources :animals do
    # Nested adoption routes - only for creating new adoptions
    resources :adoptions, controller: 'adoption', only: [:new, :create]
    
    # Direct adoption actions
    member do
      post :adopt, to: 'adoption#quick_adopt'
      delete :remove_adoption, to: 'adoption#quick_remove'
    end
    
    collection do
      get 'available', to: 'animals#available_for_adoption', as: :available
    end
  end
  
  # Standalone adoption routes - for viewing and managing adoptions
  resources :adoptions, controller: 'adoption', only: [:index, :show, :destroy]
  
  # Session management
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # Admin routes for managing adoptions
  namespace :admin do
    resources :adoptions, only: [:index, :show, :update] do
      member do
        patch :approve
        patch :reject
      end
    end
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "animals#index"
end
