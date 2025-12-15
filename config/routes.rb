Rails.application.routes.draw do
  root "exports#index"
  resources :exports, only: [:index, :show, :new, :create] do
    member do
      patch :mark_reviewed
    end
    resources :feedbacks, only: [] do
      member do
        patch :mark_reviewed
      end
    end
  end

  resource :settings, only: [:show, :update]

  namespace :api do
    post "export", to: "export#create"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
