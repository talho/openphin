ActionController::Routing::Routes.draw do |map|
  map.resources :tutorials

  map.resources :shares, :member => {:unsubscribe => :delete, :edit_audience => :get, :update_audience => :put}

#  map.resources :user_profiles, :as => "profile"
  map.connect "/jurisdictions.:format", :controller => "application", :action => "options", :conditions => {:method => [:options]}
  map.resources :devices
  map.resources :jurisdictions, :collection => [:user_alerting, :user_alerter]

  map.resources :documents, :controller => 'doc/documents', :except => [:index], :collection => [:search], :member => {:move => [:post, :put], :copy => [:post, :put]}
  map.resources :folders, :controller => 'doc/folders', :collection => [:target_folders], :member => {:move => [:post, :put] }

  map.resources :role_requests, :controller => "role_requests"
  map.resources :organization_requests, :controller => "organization_requests"
  map.resources :role_assignments, :controller => "admin/role_assignments"
  map.resources :organization_assignments, :controller => "admin/organization_assignments"
  map.resources :admin_pending_requests, :controller => "admin/pending_requests"
  map.resources :admin_role_requests, :member => [:approve, :deny], :controller => "admin/role_requests"
  map.resources :admin_invitations, :controller => "admin/invitations", :member => [:download], :collection => {:import => [:post]}
  map.reports_admin_invitation "admin_invitations/:id/reports.:format", :controller => "admin/invitations", :action => "reports", :method => [:get,:put]
  map.resources :admin_organization_requests, :member => [:approve, :deny], :controller => "admin/organization_requests"
  map.resources :admin_organization_membership_requests, :member => [:approve, :deny], :controller => "admin/organization_membership_requests"
  map.admin_organization_membership_requests "admin/organization_membership_requests/:id/:user_id", :controller => "admin/organization_membership_requests", :method => :delete
  #map.approve_admin_organization "/admin_organizations/:id/approve", :controller => "admin/organizations", :action => "approve"
  #map.deny_admin_organization    "/admin_organizations/:id/deny",    :controller => "admin/organizations", :action => "deny"
  map.resources :admin_users, :controller => "admin/users"
  map.resources :admin_user_batch, :controller => "admin/user_batch", :member => [:download], :collection => {:import => [:post], :admin_jurisdictions => [:get], :create_from_json => [:put]}
  map.resources :admin_edit_users, :controller => "admin/edit_users", :collection => {:admin_users => [:get]}

  map.resources :users do |user|
    user.resource :profile, :as => "profile", :controller => "user_profiles"
    user.resources :devices
    user.confirmation "/confirm/:token", :controller => "users", :action => "confirm"
  end

  #map.resources :alerts, :member => {:acknowledge => [:get, :put]}

  #map.connect "audits.:format", :controller => "audits", :action => "show", :method => :post
  map.resources :audits
  map.connect "/audits/list.:format", :controller => "audits", :action => "list", :conditions => {:method => [:options]}

  map.connect "/roles.:format", :controller => "application", :action => "options", :conditions => {:method => [:options]}
  map.resources :roles

  map.resources :organizations do |organization|
    organization.confirmation "/confirmation/:token", :controller => 'organizations', :action => 'confirmation'
  end
  map.resources :admin_groups, :controller => "admin/groups"
  map.dismember_admin_groups "/admin_groups/:group_id/dismember/:member_id", :controller => "admin/groups", :action => "dismember"

  map.connect "/search/show_advanced.:format", :controller => "application", :action => "options", :conditions => {:method => [:options]}
  map.show_advanced_search "/search/show_advanced.:format", :controller => "searches", :action => "show_advanced", :conditions => {:method => [:get, :post]}
  map.resource :search, :member => {:show_advanced => [:get, :post], :show_clean => [:get, :post]}
  map.dashboard "/dashboard", :controller => "dashboard", :action => "index"
  map.resources :audiences, :controller => 'audiences', :only => [:index], :collection => [:jurisdictions, :jurisdictions_flat, :roles, :groups, :determine_recipients, :recipients]
  map.root :controller => "dashboard", :action => "index"
  map.about "/about", :controller => "dashboard", :action => "about"
  map.connect "/han.:format", :controller => "application", :action => "options", :conditions => {:method => [:options]}
  map.faqs "/faqs", :controller => "dashboard", :action => "faqs"
  map.hud "/han.:format", :controller => "dashboard", :action => "hud"
  map.ext "/ext", :controller => "dashboard", :action => "index", :format => "ext"
  map.dashboard_feed_articles "/dashboard/feed_articles.:format", :controller => "dashboard", :action => "feed_articles"
  map.dashboard_news_articles "/dashboard/news_articles", :controller => "dashboard", :action => "news_articles"
  map.dashboard_menu "/dashboard/menu.js", :controller => "dashboard", :action => "menu"
  
  map.resources :user_batch, :controller => "admin/user_batch"
  map.resources :users_delete, :controller => "admin/users_delete"

  map.resources :favorites, :only => ['create', 'index', 'destroy']
  
  map.resources :forums do |forum|
    forum.resources :topics, :member => { :update_comments => :put }
  end

  map.resources :delayed_job_checks, :controller => "admin/delayed_job_checks"

  map.connect "/session.:format", :controller => "application", :action => "options", :conditions => {:method => [:options]}

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
