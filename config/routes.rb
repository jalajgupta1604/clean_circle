Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Role-based root redirects
  authenticated :user, ->(u) { u.customer? } do
    root to: "dashboard#index", as: :customer_root
  end

  authenticated :user, ->(u) { u.agent? } do
    root to: "agent/dashboard#index", as: :agent_root
  end

  authenticated :user, ->(u) { u.admin? } do
    root to: "admin/dashboard#index", as: :admin_root
  end

  # Default root
  root to: "pages#home"

  # Customer
  resource :profile, only: [:show, :edit, :update]
  resource :household, only: [:show, :edit, :update, :create, :new]
  resources :subscriptions, only: [:index, :new, :create]
  resource :wallet, only: [:show] do
    post :recharge
  end
  resources :pickups, only: [:index, :show, :new, :create]
  resources :notifications, only: [:index] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end
  get "waste_tracking", to: "waste_tracking#index"
  get "qr_code", to: "households#qr_code"

  # Agent namespace
  namespace :agent do
    get "/", to: "dashboard#index"
    resources :routes, only: [:index, :show] do
      resources :pickups, only: [:index]
    end
    resources :pickups, only: [:show, :update] do
      member do
        patch :confirm
        patch :mark_missed
      end
    end
    get "scan", to: "scanner#index"
    post "scan/verify", to: "scanner#verify"
  end

  # Admin namespace
  namespace :admin do
    get "/", to: "dashboard#index"
    resources :users
    resources :agents, only: [:index, :show, :edit, :update]
    resources :routes
    resources :households, only: [:index, :show]
    resources :pickups, only: [:index, :show, :new, :create] do
      collection do
        get :schedule
        post :batch_create
      end
    end
    resources :subscription_plans
    resources :subscriptions, only: [:index, :show]
    get "revenue", to: "revenue#index"
  end
end
