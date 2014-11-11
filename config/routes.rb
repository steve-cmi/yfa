Yfa::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
  # Shouldn't have index...
  resources :people 
  resources :news, :path => "/news"
  match 'people/:id/request_names' => 'people#takeover_request', :as => :takeover_request, :method => :post

  match 'dashboard' => 'people#dashboard', :as => :dashboard
  
  
  match 'admin' => 'admin#dashboard', :as => :admin_dashboard
  match 'admin/newsletter' => 'admin#newsletter', :as => :admin_newsletter
  match 'admin/approve_takeover/:id' => 'admin#approve_takeover', :as => :approve_takeover
  match 'admin/reject_takeover/:id' => 'admin#reject_takeover', :as => :reject_takeover
  match 'admin/approve_show/:id' => 'admin#approve_show', :as => :approve_show
  match 'admin/email_all' => 'admin#email_all', :as => :email_all
  
  
  match 'login' => 'people#dashboard', :as => :login
  match 'logout' => 'people#logout', :as => :logout
  
  match 'archives(/:term)' => 'shows#archives', :as => :archives
  
  
  resources :shows do
    get 'edit_people', :controller => :shows, :action => :edit_people, :as => :edit_people
    match 'edit_files', :controller => :shows, :action => :edit_files, :as => :edit_files, :via => [:get, :post]
    match 'remind/:showtime_id', :controller => :shows, :action => :remind, :as => :remind, :via => [:get, :post]
    get 'dashboard', :controller => :shows, :action => :dashboard, :as => :dashboard
		resources :showtimes, :only => [:show, :index]
		resources :auditions do
      get 'past', :on => :collection
    end
		member do
	    put 'auditions', :controller => :auditions, :action => :update
	  end
	end
	
	match 'auditions' => 'auditions#all'
	match 'opportunities' => 'auditions#opportunities'
	
	
	match 'search' => 'search#index', :as => :search
	match 'search/lookup' => 'search#lookup', :as => :search_lookup
	
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#index'
  
  # Hijack guide links and wrap them in a special template
  match 'resources' => 'pages#resources'
  match 'donate' => 'pages#donate'
  match 'guides/:static_file' => 'pages#guides', :as => :guides
  
  # Add legacy routes here
  # TODO: These can be removed probably a month or so after launch, remove supporting code too
  match 'audition_signup.php', :controller => :auditions, :action => :index

  # Detect show slugs last, some legacy support for now
  # TODO: build out /tickets, /reserve, etc.
  match ':url_key' => 'shows#show', :as => "vanity", :url_key => /[a-z0-9_]+/i

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  

end
