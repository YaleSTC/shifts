Shifts::Application.routes.draw do

  resources :tasks do
    member do
      post :make_entry
    end
  end

  resources :shifts_tasks
  resources :calendar_feeds
  resources :template_time_slots
  resources :stickies
  resources :announcements
  resources :links
  resources :repeating_events
  resources :restrictions
  resources :punch_clocks
  resources :punch_clock_sets
  resources :user_sessions
  resources :password_resets
  resources :user_configs, :only => [:edit, :update]
  resources :sub_requests
  resources :notices, :collection => {:archive => :get}
  resources :payform_item_sets
  resources :payform_sets
  resources :department_configs, :only => [:edit, :update]
  resources :requested_shifts
  resources :templates
  resources :payform_items
  resources :requested_shifts
  resources :templates



  resources :stats do
    collection do
      get  :for_user
      post :for_user
      get  :for_location
      post :for_location
      get  :index
      post :index
    end
  end


  resources :app_configs, :only => [:edit, :update]
  get "app_config" => 'app_configs#edit', as: :edit_app_config

  resources :calendars do
    member do
      get  :prepare_copy
      get  :apply_schedule
      post :apply_schedule
      post :toggle
      post :copy
    end
    collection do
     get :prepare_wipe_range
     post :wipe_range
    end
  end


  scope '/firstrun' do
    with_options controller: 'first_run' do |f|
      f.match '/first_app_config', :action => 'new_app_config', :method => 'get', as: :first_app_config
      f.match '/first_department', :action => 'new_department', :method => 'get', as: :first_department
      f.match '/first_user', :action => 'new_user', :method => 'get', as: :first_user
      f.match '/create_first_app_config', :action => 'create_app_config', :method => 'post', as: :create_first_app_config
      f.match '/create_first_department', :action => 'create_department', :method => 'post', as: :create_first_department
      f.match '/create_first_user', :action => 'create_user', :method => 'post', as: :create_first_user
    end
  end

  match 'login' => 'user_sessions#new', as: :login
  match 'logout' => 'user_sessions#destroy', as: :logout

  match "email_reminders", :controller => 'payforms', :action => 'email_reminders', as: :email_reminders
  match "reminders_advanced_options", :controller => 'payforms', :action => 'reminders_advanced_options', as: :reminders_advanced_options
  match  "warnings_advanced_options", :controller => 'payforms', :action => 'warnings_advanced_options', as: :warnings_advanced_options

  #TODO: get rid of sessions controller and move logout action to user_session controller and name it cas_logout
  match "cas_logout", :controller => 'sessions', :action => 'logout', as: :cas_logout
  match 'calendar_feeds/grab/:user_id/:token.:format', :controller => 'calendar_feeds', :action => 'grab', as: :calendar_feed

  # routes for managing superusers
  match "superusers", :controller => 'superusers', as: :superusers
  match "superusers/add", :controller => 'superusers', :action => 'add', as: :add_superusers
  match "superusers/remove", :controller => 'superusers', :action => 'remove', as: :remove_superusers

  resources :payforms, :shallow => true do
    collection do
      get :index
      post :index
      delete :prune
      get :go
      post :search
      get :search
      post :search
    end
    member do
      get :submit
      get :unsubmit
      get :approve
      get :skip
      get :unskip
      get :unapprove
      get :print
    end
    resources :payform_items do
      member do
        get :delete
      end
    end
  end


  resources :time_slots do
    member { get :rerender } #TODO: What should this be nested under, if anything?
  end

  resources :shifts, :shallow => true do
    member do
      get :rerender
    end
    collection do
      get :unscheduled, as: :new_unscheduled
      get :show_active
      get :show_unscheduled
    end
    resource :report do
      resources :report_items
    end
    #NOTE: "sub_requests" is a clearer model name, we use subs for routing
    resources :sub_requests, as: "subs" do
      member do
        put :take
        get :get_take_info
      end
    end
  end

  resources :users do
    collection do
      post :update_superusers
    end
    member do
      get   :toggle
      post  :toggle
    end
    resources :punch_clocks
  end

  resources :reports, :except => [:new] do
    member do
      get :popup
    end
    resources :report_items
  end

  resources :public_view do
    member do
      get  :for_location
      post :for_location
    end
  end

  resources :users do
    collection do
      post :update_superusers
    end
    member do
      post :toggle
      get :toggle
    end
    resources :punch_clocks
  end

  #TODO Fix report items routing, this is temporary
  resources :locations, except: [:index, :show, :edit, :find_allowed_locations, :new, :update, :create, :destroy] do
    collection do
      get  :display_report_items
      post :display_report_items
      get  :toggle
      post :toggle
    end
  end
  #resources :locations, :collection => {:display_report_items => [:post, :get], :toggle => [:post, :get], :index => [:post, :get]}, :except => [:index, :show, :edit, :find_allowed_locations, :new, :update, :create, :destroy]

  resources :data_types do
    resources :data_fields
    resources :data_objects, only: [:new, :create, :index]
  end

  resources :data_objects do
    resources :data_entries do
      member do
        put :edit
        put :update
      end
    end
  end

  resources :departments, :shallow => true do
    resources :users do
      collection do
        get :import
        get :mass_add
        post :mass_create
        get :autocomplete
        post :restore
        post :search
        post :save_import
      end
    end
    resources :loc_groups
    resources :locations
    resources :roles do
      member do
        get  :users
        post :users
      end
    end
    resources :categories
  end

  resources :user_profile_fields
  resources :user_profiles do
    collection do
      post :search
    end
  end

  match "/facebook", :controller => "user_profiles", :action => "facebook", as: :facebook
  match "/email_group", :controller => "shifts", :action => "email_group", as: :email_group

  resources :punch_clock_sets

  # permissions are always created indirectly so there we only need an index method to list them
  resources :permissions, :only => :index

  resources :stats do
    collection do
      post :for_user
      get :for_user
      post :for_location
      get :for_location
      get  :index
      post :index
    end
  end

  #map.report_items 'report_items/for_location', :controller => 'report_items', :action => 'for_location'

  match '/dashboard', :controller => 'dashboard', :action => 'index', as: :dashboard
  match '/access_denied', :controller => 'application', :action => 'access_denied', as: :access_denied

	resources :templates  do
    collection do
      post :update_locations
    end
		resources :requested_shifts
		resources :shift_preferences
		resources :template_time_slots
  end

  root to: "dashboard#index"

  get '/status' => 'status#index'

  match ':controller/:action/:id'
  match ':controller/:action/:id.:format'

  match '/test_new_lists', :controller => 'reports', :action => 'tasks_and_objects_list', as: :test_new_lists
  match '/update_data_objects', :controller => 'data_objects', :action => 'update_data_objects', as: :update_data_objects
  match '/active_tasks', :controller => 'tasks', :action => 'active_tasks', as: :active_tasks

  match "/delayed_job" => DelayedJobWeb, :anchor => false
end
