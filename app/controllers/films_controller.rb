class FilmsController < ApplicationController  
	
	skip_before_filter :force_auth, :only => [:film, :index]
	before_filter :fetch_film, :except => [:index, :new, :create]
	before_filter :auth, :except => [:index, :film, :new, :create]

	def index
		@active_nav = :films
		@page_name = 'Upcoming Films'

		@this_semester = Film.this_semester.by_date.reverse_order
		@next_semester = Film.next_semester.by_date.reverse_order
		@last_semesters = Film.last_semesters.by_date.reverse_order

		@groups = [
			[Yale::this_semester_label, @this_semester],
			[Yale::next_semester_label, @next_semester],
		] + @last_semesters.group_by(&:year).to_a

	end
	
	def show
		@active_nav = :films
		@page_name = @film.title
	end

	def dashboard
		@page_name = "Dashboard - #{@film.title}"
	end
	
	def new
		@film = Film.new
		@page_name = 'New Film'
		render :edit
	end
	
	def create
		@film = Film.new
		@film.approved = false
		update
	end
	
	def edit
		@page_name = "Edit Film - #{@film.title}"
	end

	def edit_people
		@page_name = "Edit Cast &amp Crew - #{@film.title}"
	end

	def edit_files
		@page_name = "Edit Files - #{@film.title}"
		@film.s3_destroy(params[:destroy_files])
	end

	def update
		# Process blanks to nils
		params[:film].each {|key,val| val = nil if val.blank? }

		# Handle file uploads
		if (params[:film][:file])
		  @film.s3_create(params[:film][:file])
		  redirect_to film_edit_files_path(@film), :notice => "File uploaded"
			return
		end
		
		# Process screenings
		if params[:film][:screenings_attributes]
			params[:film][:screenings_attributes].each do |key, obj| 
				# Merge date and time strings into a starts_at datetime.
				obj[:starts_at] = Time.zone.parse("#{obj.delete(:date)} #{obj.delete(:time)}") rescue nil

				# Remove it if it doesn't have the needed fields
				if obj[:starts_at].blank?
					params[:film][:screenings_attributes].delete(key) 
					next
				end
			end
		end
		
		# Process permissions
		if params[:film][:permissions_attributes]
			params[:film][:permissions_attributes].each do |key, obj|
				params[:film][:permissions_attributes].delete(key) if obj[:person_id].blank?
				obj.delete(:name)
			end
		end

		# Process film_positions
		if params[:film][:film_positions_attributes]
			params[:film][:film_positions_attributes].each do |key, obj|
				
				# Find or create person by name (adds new people if they don't exist)
				if obj[:person_id].blank? && !obj[:name].blank?
					fname, lname = obj[:name].split(' ', 2)
					person = Person.find_or_create_by_fname_and_lname(fname, lname)
					obj[:person_id] = person.id
				end

				# Convert blanks to nils
				obj[:listing_order] = nil if obj[:listing_order].blank?
				obj[:person_id] = nil if obj[:person_id].blank?

				# Remove it if it doesn't have a position (or character, for actors)
				if obj[:position_id].blank? || (obj[:position_id] == Position.actor_id && obj[:character].blank?)
					params[:film][:film_positions_attributes].delete(key)
				end
			end
		end
		
		if !@film.id
			post_create = {}
			post_create[:permissions_attributes] = params[:film][:permissions_attributes]
			params[:film].delete(:permissions_attributes)
		end
		
		respond_to do |format|
	    if @film.update_attributes(params[:film])
	    	# Add permissions for this person to the film if they tried to delete them
	    	if !@current_user.site_admin? && !@film.permissions.detect{|sp| sp.person_id == @current_user.id}
	    		@film.permissions.create(:person_id => @current_user.id)
	    		@film.save!
	    	end

	    	# If it is a new film, now we can ammend permissions and other related models
	    	if post_create
	    		 @film.update_attributes(post_create)
	    	end

	    	# Tell the FilmMailer to send an approval Email to the admin after save
        FilmMailer.need_approval_email(@film).deliver if params[:id].blank?

	      format.html do 
	      	if params[:id].blank?
	      		redirect_to(film_edit_people_path(@film))
	      	else
	      		redirect_to(film_dashboard_path(@film), :notice => 'Film was successfully updated.')
	      	end
	      end
	      format.json { render :json => {:success => true} }
	      format.js { render :action => "edit_success" }
	    else
	      format.html { render :action => "edit" }
	      format.json { render :json => {:error => true} }
	      format.js { render :nothing => true }
	    end
	  end
	end
	
	def destroy
		@film.destroy
		# Admin dash will redirect normal people to user dash
		redirect_to admin_dashboard_path
	end
	
	private
	
	def fetch_film
		film_id = params[:film_id] || params[:id]
		@film = Film.unscoped.includes(:film_positions => [:person, :position]).find(film_id) if film_id
		raise ActionController::RoutingError.new('Not Found') unless @film && (@film.approved || @current_user.has_permission?(@film))
	end

	def auth
		return true if @current_user.has_permission?(@film)
		raise ActionController::RoutingError.new('Not Found')		
	end	
end
