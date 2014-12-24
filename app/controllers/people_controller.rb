class PeopleController < ApplicationController  

	skip_before_filter :force_auth, :only => [:show, :logout]
	before_filter :verify_user, :except => [:show, :dashboard, :logout, :new, :create]
	before_filter :verify_admin, :only => [:add_admin, :update_admin, :remove_admin]
	before_filter :fetch_user, :except => [:dashboard, :logout, :new, :create]

	def show
		@page_name = @person.display_name
		@film_positions = @person.film_positions.includes(:film, :position).order('films.start_date DESC')
		@editable = (@current_user and @person.id == @current_user.id)
	end
	
	def dashboard
		@active_nav = :user
		@active_subnav = :dashboard
		@page_name = "My Dashboard"
		@user = @current_user
	end
	
	def edit
		@active_nav = :user
		@active_subnav = :dashboard
		@page_name = "Edit My Account"
		@user = @current_user
	end
	
	# New User step 1
	def new
		redirect_to @current_user if @current_user # They must be CAS authed no we're OK
		@person = Person.new(:year => Date.today.year + 4)
		@person.netid = session[:cas_user]
		@person.populateLDAP
		@current_user = @person
	end
	
	# Designed to be indemnipotent in case they refresh the page and re-submit
	def create
		@person = Person.new unless @current_user
		@person.netid = session[:cas_user] unless @current_user
		if @current_user || @person.update_attributes(params[:person])
			#Let's check to see if they have any recommended people they match. If so, send them there, otherwise take them away
			@person ||= @current_user
			if not @person.similar_users.empty?
				render :new_step2
			else
				url = session[:user_flow_entry]
				session[:user_flow_entry] = nil
				url ||= dashboard_path
				redirect_to url, :notice => "Profile created successfully. Enjoy the new site!"
			end			
		else
			flash.now[:alert] = "There was an error with the data you entered, please try again!"
			render :new
		end
	end
	
	def takeover_request
		# Asking to match people, let's do it
		# We'll allow multiple requests for a name and let the admin sort it out...
		params[:person_ids] ||= []
		params[:person_ids].each do |person_id|
			TakeoverRequest.create(:person => @current_user, :requested_person_id => person_id, :approved => false)
		end
		if session[:user_flow_entry]
			url = session[:user_flow_entry]
			session[:user_flow_entry] = nil
			redirect_to url, :notice => "Profile created successfully. Enjoy the new site!"
		else
			redirect_to dashboard_path, :notice => "Takeover request successful!"
		end
	end
	
	def update
		respond_to do |format|
	    if @person.update_attributes(params[:person])
	      format.html { redirect_to(dashboard_path(@person), :notice => 'User was successfully updated.') }
	      format.json { render :json => {:success => true} }
	      format.js { render :json => {:success => true} }
	    else
	      format.html { render :action => "edit" }
	      format.json { render :json => {:success => false} }
	      format.js { render :json => {:success => false} }
	    end
	  end
	end

	def add_admin
		@person.site_admin = true
		@person.admin_admin = false
		if @person.save
			redirect_to admin_admins_path, :notice => "Admin was successfully added."
		else
			redirect_to admin_admins_path, :error => "Admin was unable to be added."
		end
	end
	
	def update_admin
		[:site_admin, :admin_admin].each do |column|
			if params[:person] and params[:person][column]
				@person.send("#{column}=", params[:person].delete(column))
			end
		end
		if @person.save
			render :json => {:success => true}
		else
			render :json => {:success => false}
		end
	end

	def remove_admin
		@person.site_admin = false
		@person.admin_admin = false
		if @person.save
			redirect_to admin_admins_path, :notice => "Admin was successfully removed."
		else
			redirect_to admin_admins_path, :error => "Admin was unable to be removed."
		end
	end
	
	def logout
		@current_user = nil
		reset_session
		CASClient::Frameworks::Rails::Filter.logout(self)
	end
	
	private
	
	def fetch_user
		@person = Person.find(params[:id] || params[:person_id])
	end
	
	def verify_user
		raise ActionController::RoutingError.new('Forbidden')	unless @current_user && (@current_user.friendly_id.to_s == params[:id] || @current_user.site_admin?)
	end
	
	def verify_admin
		raise ActionController::RoutingError.new('Forbidden')	unless @current_user && @current_user.site_admin?
	end

end