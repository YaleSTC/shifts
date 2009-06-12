ActionController::Routing::Routes.draw do |map|

  map.resources :payform_item_sets

  map.resources :payform_sets

  map.resources :payforms, :collection => { :prune => :delete, :go => :get }, :shallow => true do |payforms|
    payforms.resources :payform_items
  end

  map.resources :payform_items

  map.resources :time_slots #TODO: What should this be nested under, if anything? (probably not)

  map.resources :shifts, :shallow => true do |shifts|
    shifts.resources :reports
    shifts.resources :sub_requests, :as => "subs" #NOTE: "sub_requests" is a clearer model name, we use subs for routing
    shifts.resources :report_items
  end



  map.resources :departments, :shallow => true do |departments|
    departments.resources :users, :collection => {:mass_add => :get, :mass_create => :post, :restore => :post}
    departments.resources :loc_groups
    departments.resources :locations
    departments.resources :roles
    departments.resources :categories
  end

  map.resources :permissions, :only => :index
  map.access_denied '/access_denied', :controller => 'application', :action => 'access_denied'
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
  map.root :controller => "departments"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

