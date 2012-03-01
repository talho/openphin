ActionController::Routing::Routes.draw do |map|

  map.resources :devices, :only => [:create,:destroy]
  map.resources :jurisdictions, :collection => [:user_alerting, :user_alerter]
  map.resources :audiences, :only => [:index], :collection => [:jurisdictions, :jurisdictions_flat, :roles, :groups, :determine_recipients, :recipients]

  map.resources :roles
  map.resources :role_requests, :only => [:new,:create]

  map.resources :users do |user|
    user.resource :profile, :as => "profile", :controller => "user_profiles", :except => [:destroy]
    user.resources :devices, :only => [:create,:destroy]
    user.is_admin "/is_admin.:format", :controller => "users", :action => "is_admin", :conditions => {:method => [:get]}
  end
  map.resource :search, :member => {:show_advanced => [:post, :get], :show_clean => [:get, :post]}

  map.namespace(:admin) do |admin|
    admin.resources :organizations, :collection => {:confirmation => [:post]}
    admin.resources :groups do |groups|
      groups.dismember "/dismember/:member_id(.:format)", :action => "dismember", :conditions => {:method => :post}
    end
#    admin.resources :pending_requests
    admin.resources :role_requests, :except => [:edit,:update], :member => {:approve => :get, :deny => :get}
    admin.resources :invitations, :only => [:index,:show,:create], :member => {:download => :get}, :collection => {:import => :post, :recipe_types => :get }
    admin.resources :users, :only => [:new,:create], :collection => {:deactivate => :post}
    admin.resources :edit_users, :only => [:update], :collection => {:admin_users => [:get]}
    admin.resources :user_batch, :only => [:new,:create], :member => [:download], :collection => {:import => [:post], :admin_jurisdictions => [:get], :create_from_json => [:put]}
  end
  map.resources :role_assignments, :controller => "admin/role_assignments"  # malicious testing

# vvvvvv
  map.resources :user_batch, :controller => "admin/user_batch"
  map.resources :delayed_job_checks, :controller => "admin/delayed_job_checks"

  map.resources :alerts, :only => [:show, :update], :collection => [:recent_alerts]
  map.alert_with_token '/alerts/:id/show_with_token/:token.:format', :controller => 'alerts', :action => 'show_with_token', :method => :get
  map.update_alert_with_token '/alerts/:id/update_with_token/:token.:format', :controller => 'alerts', :action => 'update_with_token', :method => :put

  map.resources :favorites, :only => [:create, :index, :destroy]
  map.resources :documents, :controller => 'doc/documents', :except => [:index], :collection => [:search, :recent_documents], :member => {:move => [:post, :put], :copy => [:post, :put]}
  map.resources :folders, :controller => 'doc/folders', :collection => [:target_folders], :member => {:move => [:post, :put] }
  map.resources :shares, :member => {:unsubscribe => :delete, :edit_audience => :get, :update_audience => :put}
  map.resources :organizations, :only => [:index]
  map.resources :forums do |forum|
    forum.resources :topics, :collection => {:active_topics => :get, :recent_posts => :get}, :member => { :update_comments => :put }
  end
  map.namespace :report do |report|
    report.resources :reports, :member => { :filters => :get, :reduce => :post }
    report.resources :recipes, :only => [:index,:show], :requirements => {:id =>  /Report::([A-Z][a-z]+)+Recipe/}
  end

  map.resources :audits, :collection => [:models]
  map.rss_feed '/rss_feed.:format', :controller => 'rss_feed', :action => 'index', :conditions => {:method => [:get, :post]}
  map.resources :tutorials

  map.connect '/*path(.:format)', :controller => 'application', :action => 'options', :conditions => {:method => :options}

  map.resources :dashboard, :collection => {:all => :get, :menu => :get, :faqs => :get}
  map.root :controller => "dashboard", :action => "index", :format => "ext"
  map.about_dashboard "/about", :controller => "dashboard", :action => "about"
  map.about_talhophin "/about_talhophin", :controller=> "dashboard", :action=> "about_talhophin"
  map.hud "/han.:format", :controller => "dashboard", :action => "hud"
  map.ext "/ext", :controller => "dashboard", :action => "index", :format => "ext"
  map.resources :session, :controller => 'sessions', :only => [:new, :create, :destroy]
  map.sign_out '/sign_out', :controller => 'sessions', :action => 'destroy', :method => :delete
  map.sign_in '/sign_in', :controller => 'sessions', :action => 'new' 
  Clearance::Routes.draw(map)

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/auto_complete_for_phin_person_display_name', :action => "auto_complete_for_phin_person_display_name", :format => "json"
  #map.connect ':controller/auto_complete_for_phin_person_first_name', :action => 'auto_complete_for_phin_person_first_name', :format => 'json'
  #map.connect ':controller/auto_complete_for_phin_person_last_name', :action => "auto_complete_for_phin_person_last_name", :format => "json"
  # map.auto_complete ':controller/:action', :requirements => { :action => /auto_complete_for_\S+/ }, :conditions => { :method => :get }

  # map.connect ':controller/:action/:id'
  # map.connect ':controller/:action/:id.:format'
end
