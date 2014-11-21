class PeopleController < ApplicationController  

	skip_before_filter :force_auth, :only => [:film, :logout]
	before_filter :verify_user, :except => [:film, :dashboard, :logout, :new, :create]
	before_filter :fetch_user, :except => [:dashboard, :logout, :new, :create]

	def show
		@page_name = @person.display_name
		@film_positions = @person.film_positions.includes(:film, :position).order('films.start_date DESC')
		@editable = (@current_user and @person.id == @current_user.id)
	end
	
	def film
		# Show public view
		#TODO: SHould we cache people's public profiles?
		#TODO: Should admins be able to edit?
		@page_name = @person.display_name
		@film_positions = @person.film_positions.includes({:film => :screenings}, :position)
		@film_positions = @film_positions.select{|sp| sp.film}.sort_by{|sp| sp.film.screenings.first.timestamp}.reverse
	end
	
	def dashboard
		#Determine type of user dashboard to film
		@films = Film.unscoped.includes(:screenings).find(@current_user.permissions.map(&:film_id))
		@permission_map = @current_user.permissions.group_by(&:film_id)
		
		#TODO: Could probably optimize this
		@auditions = @current_user.auditions.where(["`timestamp` > ?",Time.now])
		@similar_people = @current_user.similar_to_me
	end
	
	# New User step 1
	def new
		redirect_to @current_user if @current_user # They must be CAS authed no we're OK
		@person = Person.new
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
			@matches = @person.similar_to_me
			if @matches.length > 0
				render :new_step2
			else
				url = session[:user_flow_entry]
				session[:user_flow_entry] = nil
				url ||= dashboard_path
				redirect_to url, :notice => "Profile created successfully. Enjoy the new site! And if you need help, check out the learn tab above."
			end			
		else
			flash.now[:error] = "There was an error with the data you entered, please try again!"
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
			redirect_to url, :notice => "Profile created successfully. Enjoy the new site! And if you need help, check out the learn tab above."
		else
			redirect_to dashboard_path, :notice => "Takeover request successful!"
		end
	end
	
	def update
		respond_to do |format|
	    if @person.update_attributes(params[:person])
	      format.html { redirect_to(@person, :notice => 'User was successfully updated.') }
	      format.json { respond_with_bip(@person) }
	    else
	      format.html { render :action => "edit" }
	      format.json { respond_with_bip(@person) }
	    end
	  end
	end
	
	def logout
		@current_user = nil
		reset_session
		CASClient::Frameworks::Rails::Filter.logout(self)
	end
	
	private
	
	def fetch_user
		@person = Person.find(params[:id])
	end
	
	def verify_user
		raise ActionController::RoutingError.new('Forbidden')	unless @current_user && (@current_user.id == params[:id].to_i || @current_user.site_admin?)
	end
	
end