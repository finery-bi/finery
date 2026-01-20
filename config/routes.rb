Blazer::Engine.routes.draw do
  resources :queries do
    post :run, on: :collection # err on the side of caution
    post :cancel, on: :collection
    post :refresh, on: :member
    get :tables, on: :collection
    get :schema, on: :collection
    get :docs, on: :collection
  end

  resources :checks, except: [:show] do
    get :run, on: :member
  end

  resources :dashboards, except: [:index] do
    post :refresh, on: :member
  end

  if Blazer.uploads?
    resources :uploads do
    end
  end

  # AI endpoints
  scope :ai, controller: :ai do
    post :generate_sql
    post :explain
    post :fix_error
    post :summarize
    post :suggest_optimizations
    get :status
  end

  root to: "queries#home"
end
