class FilmsController < ApplicationController  
	
	skip_before_filter :force_auth, :only => [:film, :index]
	before_filter :fetch_film, :except => [:index, :new, :create]
	before_filter :auth, :except => [:index, :film, :new, :create, :dashboard]

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
		# People can see this as long as they have SOME permission
		raise ActionController::RoutingError.new('Not Found') unless @current_user.has_permission?(@film)
		@page_name = "Dashboard - #{@film.title}"
		@recent_auditions = @film.auditions.recent_past
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
		@page_name = 'Edit Film'
	end

	def edit_people
		@page_name = 'Edit Film'
	end

	def edit_files
		@page_name = 'Edit Film'
		@film.s3_destroy(params[:destroy_files])
	end

	def update
		# Process blanks to nils
		params[:film].each {|key,val| val = nil if val.blank? }

		# handle file uploads
		if (params[:film][:file])
		  @film.s3_create(params[:film][:file])
		  redirect_to film_edit_files_path(@film), :notice => "File uploaded"
			return
		end
		
		#Process screenings to timestamps
		if params[:film][:screenings_attributes].blank? && @film.screenings.count == 0
			@film = Film.new
			render :action => "edit", :notice => 'You must give at least one screening'
			return
		end
		if params[:film][:screenings_attributes]
			params[:film][:screenings_attributes].each do |key,obj| 
				# Remove it if it doesn't have the needed fields
				if obj[:date].blank? || obj[:time].blank?
					params[:film][:screenings_attributes].delete(key) 
					next
				end

				# Format the date properly into a time object and use the current server TS to get UTC offset they meant
				that_date =  DateTime.strptime("#{obj[:date]} #{obj[:time]}", '%m/%d/%Y %l:%M%P')
				obj = { :id => obj[:id], :timestamp => Time.find_zone('Eastern Time (US & Canada)').local(that_date.year, that_date.month, that_date.day, that_date.hour, that_date.minute), :_destroy => obj[:_destroy] }
				params[:film][:screenings_attributes][key] = obj	
			end
		end
		
		#Process person_ids where applicable
		if params[:film][:film_positions_attributes]
			params[:film][:film_positions_attributes].each do |key,obj|
				
				# Create person if not exists
				if obj[:person_id].blank? && !obj[:name].blank?
					name = obj[:name].split
					person = Person.create!(:fname => name[0], :lname => name[1..-1].join(" "))
					obj[:person_id] = person.id
				end
				obj = { :id => obj[:id], 
								:assistant => obj[:assistant], 
								:position_id => obj[:position_id], 
								:person_id => obj[:name].blank? ? nil : obj[:person_id], 
								:character => obj[:character], 
								:listing_order => obj[:listing_order].blank? ? nil : obj[:listing_order], 
								:_destroy => obj[:_destroy]
							}
				params[:film][:film_positions_attributes][key] = obj

				# Remove it if it doesn't have a position
				params[:film][:film_positions_attributes].delete(key) if obj[:position_id].blank? || (obj[:position_id] == "17" && obj[:character].blank?)
			end
		end
		
		#Process permissions to remove names
		if params[:film][:permissions_attributes]
			params[:film][:permissions_attributes].each do |key,obj|
				params[:film][:permissions_attributes].delete(key) if obj[:person_id].blank?
				obj.delete(:name)
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
		@film = Film.unscoped.includes(:film_positions => [:person, :position]).find(params[:id]) if params[:id]
		raise ActionController::RoutingError.new('Not Found') unless @film && (@film.approved || @current_user.has_permission?(@film))
	end

	def auth
		return true if @current_user.has_permission?(@film)
		raise ActionController::RoutingError.new('Not Found')		
	end	
end
