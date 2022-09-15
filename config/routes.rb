Rails.application.routes.draw do

  namespace :vfw do
    resources :post, only: [:index] do
      member do 
        get :voucher
      end
        
    end

    resources :audit do
      collection do
        get :home
        get :pdf
        get :print
        get :edit
        patch :update_config
      end
    end 
  end

  resources :bank_statements do 
    member do 
      get :transactions
      get :reconcile
      get :update_reconcile
      post :clear_splits
      post :unclear_splits

    end
    collection do 
      get :unlinked
    end
  end
  resources :bank_transactions, except:[:index] do 
    collection do 
      get :upload_ofx
      patch :update_ofx
      patch :import_ofx
    end
  end

  namespace :entries do
    resources :duplicate, only: [:show]
    resources :void, only: [:show, :update]
    resources :search, only: [:edit, :update]
    resources :filter, only: [:index] 
    # do
    #   member do 
    #     post :filter
    #     get :filtered
    #   end
    # end
    resources :filtered, only: [:index,:update]
    resources :auto_search, only: :index

  end

  resources :entries do 
    member do 
      get :link 
      get :new_bt

    end
  end

  resources :accounts do
    member do 
      get :new_child
    end
    collection do
      get :index_table
    end
  end
  namespace :accounts do
    resources :register_pdf, only: :show
    resources :split_register_pdf, only: :show
  end


  namespace :books do
    # resources :importyaml, only: [:new,:create]
    # resources :open, only: :show
    resources :setup do
      get :preview
      get :create 
    end
  
    # , only: [:show, :index, :edit, :new]
  end
  resources :books do 
    member do 
      get :open
    end
  end
  resources :users do 
    member  do
      get :profile
      patch :update_profile
    end
  end

  resources :clients do
    collection do
      post :signin
      get :home
    end
    member do 
      get :visit
      get :leave
    end
  end

  resources :reports, only: :index do
    collection do
      get :profit_loss
      get :trial_balance
      get :checking_balance
      get :register_pdf
      get :split_register_pdf
      get :summary
      patch :set_acct
      get :set_acct

    end
    member do
      post :split_clear
      post :split_unclear
    end
  end
  get 'about/about'
  get 'about/accounts'
  get 'about/entries'
  get 'about/banking'
  get 'about/reports'
  get 'about/checking'
  get 'about', to: 'about#about'
  get 'home/index'
  get 'home/client'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  get 'login', to: 'clients#login', as: 'login'
  get 'logout', to: 'clients#logout', as: 'logout'
  get 'profile', to: 'users#profile'
  get 'vfw', to: 'vfw/post#index', as: 'vfw'
  root "home#index"
  get '*path', to: 'home#redirect'

end
