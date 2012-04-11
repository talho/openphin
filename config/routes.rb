Openphin::Application.routes.draw do
  resources :roles
  resources :jurisdictions do
    collection do
      get :user_alerting
      get :user_alerter
    end
  end
  resources :audiences, :only => [:index] do
    collection do
      get :jurisdictions
      get :jurisdictions_flat
      post :jurisdictions_flat
      get :roles
      get :groups
      get :determine_recipients
      get :recipients
    end
  end

  resources :users do
    resource :profile, :controller => "user_profiles", :except => [:destroy]
    resources :devices, :only => [:create, :destroy]
    match '/is_admin.:format' => 'users#is_admin', :as => :is_admin, :via => [:get]
  end
  resource :search do
    member do
      post :show_advanced
      get :show_advanced
      post :show_clean
      get :show_clean
    end
  end

  namespace :admin do
      resources :organizations do
        collection do
          post :confirmation
          get :requests
        end
      end
      resources :organization_membership_requests, :only => [:index, :update, :destroy]
      resources :groups do
          match '/dismember/:member_id(.:format)' => '#dismember', :as => :dismember, :via => :post
      end
      resources :role_requests, :except => [:edit, :update] do
        member do
          get :approve
          get :deny
        end
      end
      resources :invitations, :only => [:index, :show, :create] do
        collection do
          post :import
          get :recipe_types
        end
        get :download, :on => :member
      end
      resources :users, :only => [:new, :create] do
         post :deactivate, :on => :collection
      end
      resources :edit_users, :only => [:update] do
        get :admin_users, :on => :collection
      end
      resources :user_batch, :only => [:new, :create] do
        collection do
          post :import
          get :admin_jurisdictions
          put :create_from_json
        end
        get :user_batch, :on => :member
      end
      resources :delayed_job_checks
  end
  resources :role_assignments, :controller => 'admin/role_assignments'
  
  resources :alerts, :only => [:show, :update] do
    get :recent_alerts, :on => :collection
  end
  match '/alerts/:id/show_with_token/:token.:format' => 'alerts#show_with_token', :as => :alert_with_token, :method => :get
  match '/alerts/:id/update_with_token/:token.:format' => 'alerts#update_with_token', :as => :update_alert_with_token, :method => :put
  
  resources :organizations, :only => [:index]
  resources :role_requests, :only => [:new, :create]
  resources :devices, :only => [:create, :destroy]
  resources :favorites, :only => [:create, :index, :destroy]
  
  resources :documents, :controller => 'doc/documents', :except => [:index] do
    collection do
      get :search
      get :recent_documents
    end
    member do
      post :move
      put :move
      post :copy
      put :copy
    end
  end
  resources :folders, :controller => 'doc/folders' do
    get :target_folders, :on => :collection
    member do
      post :move
      put :move
    end
  end
  resources :shares do
    member do
      delete :unsubscribe
      get :edit_audience
      put :update_audience
    end
  end

  resources :forums do
    resources :topics do
      collection do
        get :active_topics
        get :recent_posts
      end
      put :update_comments, :on => :member
    end
  end

  namespace :report do
    resources :reports do
      member do
        get :filters
        post :reduce
      end
    end
    resources :recipes, :only => [:index, :show]
  end

  resources :audits do
    get :models, :on => :collection
  end

  match '/rss_feed.:format' => 'rss_feed#index', :as => :rss_feed, :via => [:get, :post]
  resources :tutorials
  match '/*path(.:format)' => 'application#options', :via => :options

  resources :dashboard do
    collection do
      get :all
      get :menu
      get :faqs
    end
  end
  root :to => 'dashboard#index', :format => 'ext'
  match '/about' => 'dashboard#about', :as => :about_dashboard
  match '/about_talhophin' => 'dashboard#about_talhophin', :as => :about_talhophin
  match '/han.:format' => 'dashboard#hud', :as => :hud
  match '/ext' => 'dashboard#index', :as => :ext, :format => 'ext'
  resources :sessions, :only => [:new, :create, :destroy]
  match '/sign_out' => 'sessions#destroy', :as => :sign_out, :method => :delete
  match '/sign_in' => 'sessions#new', :as => :sign_in
end