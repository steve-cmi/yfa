Yfa::Application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'

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
  resources :people do
    collection do
      post :add_admin
    end
    put :update_admin
    post :remove_admin
  end
  resources :events do
    collection do
      post :set_featured
    end
  end
  resources :jobs
  resources :announcements do
    collection do
      post :update_all
    end
  end
  resources :activities
  resources :genres
  resources :filters
  resources :positions
  resources :carousels do
    collection do
      post :update_all
    end
  end
  resources :buildings do
    collection do
      post :update_all
    end
  end
  resources :pages do
    collection do
      match 'howtos', :as => :howtos
      match 'donate', :as => :donate
      post :update_all
    end
  end
  
  match 'people/:id/request_names' => 'people#takeover_request', :as => :takeover_request, :method => :post

  match 'dashboard' => 'people#dashboard', :as => :dashboard
  
  match 'admin' => 'admin#dashboard', :as => :admin_dashboard

  match 'admin/announcements' => 'admin#announcements', :as => :admin_announcements
  match 'admin/carousels' => 'admin#carousels', :as => :admin_carousels
  match 'admin/jobs' => 'admin#jobs', :as => :admin_jobs
  match 'admin/pages' => 'admin#pages', :as => :admin_pages
  match 'admin/events' => 'admin#events', :as => :admin_events
  match 'admin/films' => 'admin#films', :as => :admin_films
  match 'admin/admins' => 'admin#admins', :as => :admin_admins

  match 'admin/approve_takeover/:id' => 'admin#approve_takeover', :as => :approve_takeover
  match 'admin/reject_takeover/:id' => 'admin#reject_takeover', :as => :reject_takeover
  match 'admin/approve_film/:id' => 'admin#approve_film', :as => :approve_film
  match 'admin/approve_event/:id' => 'admin#approve_event', :as => :approve_event
  match 'admin/email_all' => 'admin#email_all', :as => :email_all
  
  match 'login' => 'people#dashboard', :as => :login
  match 'logout' => 'people#logout', :as => :logout
  
  match 'archives(/:term)' => 'films#archives', :as => :archives
  
  resources :films do
    get 'dashboard', :controller => :films, :action => :dashboard, :as => :dashboard
    get 'edit_people', :controller => :films, :action => :edit_people, :as => :edit_people
    match 'edit_files', :controller => :films, :action => :edit_files, :as => :edit_files, :via => [:get, :post]
		resources :auditions do
      get 'past', :on => :collection
    end
		member do
	    put 'auditions', :controller => :auditions, :action => :update
	  end
	end
	
	match 'auditions' => 'auditions#cast'
	match 'opportunities' => 'auditions#crew'
	
	match 'search' => 'search#index', :as => :search
	match 'search/lookup' => 'search#lookup', :as => :search_lookup
	
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'pages#index'
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

end
