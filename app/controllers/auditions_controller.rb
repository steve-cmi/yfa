# Sorry, this controller is the messiest. It's bad

class AuditionsController < ApplicationController

	skip_before_filter :force_auth, :only => [:cast, :crew]
	before_filter :fetch_film, :except => [:cast, :crew]

	# Cast Opportunities
	def cast
		@active_nav = :opportunities
		@scopes = [:cast, :crew]
		@scope = :cast
		@films = Film.current.has_auditions.includes(:auditions)
	end

	# Crew Opportunities
	def crew
		@active_nav = :opportunities
		@scopes = [:cast, :crew]
		@scope = :crew
		@film_positions = FilmPosition.current.crew.vacant.includes(:film, :position)
		@film_positions = @film_positions.filtered_by(params[:positions]) if params[:positions]
		@positions = Position.crew.all
	end

	def index
		@active_nav = :opportunities
		@auditions = [] and return if request.format == :csv && !@current_user.has_permission?(params[:film_id], :auditions)

		@auditions = @film.auditions.current
		redirect_to '/auditions' if @auditions.none? && !@current_user.has_permission?(params[:film_id], :auditions)

		@user_audition = @auditions.find_by_person_id(@current_user.id)
		@recent_auditions = @film.auditions.recent
	end

	def past
		@active_nav = :opportunities
		@auditions = @film.auditions
		unless @aud_admin and @auditions.recent.any?
			redirect_to :action => :index, :film_id => @film.id
		end
	end

	def create
		#expect batch processing so figure out what we're iterating on
		# Assume they gave us Eastern Time Zone stuff
		begin
			that_date = DateTime.strptime("#{params[:date]} #{params[:start_time]}", '%m/%d/%Y %l:%M%P')
			start = Time.find_zone('Eastern Time (US & Canada)').local(that_date.year, that_date.month, that_date.day, that_date.hour, that_date.minute)
			that_date = DateTime.strptime("#{params[:date]} #{params[:end_time]}", '%m/%d/%Y %l:%M%P')
			stop = Time.find_zone('Eastern Time (US & Canada)').local(that_date.year, that_date.month, that_date.day, that_date.hour, that_date.minute)
		rescue ArgumentError
			render :js => "alert('Invalid date format, please try again and be sure to use the dropdowns!')"
			return
		end

		# Validate things here
		# ensure there's no other time in this span, custom validator
		if @film.auditions.where(:timestamp => (start...stop)).count > 0
			#Bad params
			@auditions = @film.auditions.future.includes(:person)
			flash.now[:alert] = 'Given audition times conflict with pre-existing auditions.'
			render :action => 'index'
			return
		end

		if params[:duration].to_i <= 0
			render :js => "alert('Auditions must have a duration (in minutes) greater than 0')"
			return
		end

		while start < stop do
			@film.auditions.build(:timestamp => start, :location => params[:location])
			start += params[:duration].to_i.minutes
		end

		respond_to do |format|
			if @film.save
				format.html { redirect_to film_auditions_path(@film), :notice => 'Film was successfully updated.' }
				format.json { render :json => {:success => true} }
	      format.js { render :action => "create_success" }
			else
				render :nothing => true
			end
		end
	end

	def edit
	end

	def update

		if params[:commit] == "cancel" || params[:commit] =~ /\d+/

			# If they want to add an audition, verify params first
			if params[:commit] =~ /\d+/ && (params[:phone].blank? || params[:email].blank?)
				redirect_to film_auditions_path(@film), :alert => 'Please enter a valid phone and email so the production can contact you'
				return
			end

			# If they already had an audition
			@old_audition = @film.auditions.where(:person_id => @current_user.id).first
			@old_audition.cancel! if @old_audition

			# If they asked for a new audition
			if params[:commit] =~ /\d+/
				@audition = @film.auditions.where(:person_id => nil).find(params[:commit])
				@audition.signup! @current_user, params
			end

		elsif params[:id]
			raise unless @aud_admin
			# single update as from best in place, just assign location?
			@audition = @film.auditions.find(params[:id])
			respond_to do |format|
		    if @audition.update_attributes(params[:audition])
		      format.html { redirect_to(@film, :notice => 'Film was successfully updated.') }
		      format.json { render :json => {:success => true} }
		    else
		      format.html { render :action => "edit" }
		      format.json { render :json => {:error => true} }
		    end
		  end
		  return

		else
			raise unless @aud_admin
			destroy_ids = params[:auditions].collect {|id, values| id if values[:_destroy] == "1"}.compact
			@film.auditions.destroy(*destroy_ids) unless destroy_ids.empty?
		end

		redirect_to film_auditions_path(@film), :notice => 'Audition successfully updated.'
	end

	private

	def fetch_film
		# Hack to get the mass-update going, id is actually film_id here
		if params[:film_id].blank? && action_name == "update"
			params[:film_id] = params[:id]
			params.delete(:id)
		end

		# Check permissions, if admin, pre-load the people too
		if logged_in? && @current_user.has_permission?(params[:film_id], :auditions)
			@aud_admin = true
			@film = Film.includes(:auditions => [:person]).find(params[:film_id])
		else
			@film = Film.includes(:auditions).find(params[:film_id])
		end
	end
end
