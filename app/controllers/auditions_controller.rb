# Sorry, this controller is the messiest. It's bad

class AuditionsController < ApplicationController

	skip_before_filter :force_auth, :only => [:cast, :crew]
	before_filter :fetch_film, :except => [:cast, :crew]

	# Cast Opportunities
	def cast
		@active_nav = :opportunities
		@active_subnav = :auditions
		@scopes = [:cast, :crew]
		@scope = :cast
		@films = Film.current.has_auditions.includes(:auditions, :director)
	end

	# Crew Opportunities
	def crew
		@active_nav = :opportunities
		@active_subnav = :auditions
		@scopes = [:cast, :crew]
		@scope = :crew
		@film_positions = FilmPosition.current.crew.vacant.includes(:film, :position)
		@film_positions = @film_positions.filtered_by(params[:positions]) if params[:positions]
		@positions = Position.crew.all
	end

	def index
		@active_nav = :opportunities
		@active_subnav = :auditions
		@auditions = [] and return if request.format == :csv && !@current_user.has_permission?(params[:film_id], :auditions)

		@auditions = @film.auditions.current
		redirect_to '/auditions' if @auditions.none? && !@current_user.has_permission?(params[:film_id], :auditions)

		@user_audition = @auditions.find_by_person_id(@current_user.id)
		@recent_auditions = @film.auditions.recent
	end

	def past
		@active_nav = :opportunities
		@active_subnav = :auditions
		@auditions = @film.auditions
		unless @aud_admin and @auditions.recent.any?
			redirect_to :action => :index, :film_id => @film.id
		end
	end

	def create
		if params[:multiple] == 'true'
			create_multiple
		else
			create_single
		end
	end

	def create_multiple
		# Parse date and time inputs into start and stop.
		begin
			start = Time.zone.parse("#{params[:date]} #{params[:start_time]}")
			stop = Time.zone.parse("#{params[:date]} #{params[:end_time]}")
		rescue
			redirect_to film_auditions_path(@film), :alert => "Invalid date format, please try again."
			return
		end

		# Ensure there are no other times in this time span
		if @film.auditions.where(:starts_at => (start...stop)).count > 0
			redirect_to film_auditions_path(@film), :alert => "Given audition times conflict with pre-existing auditions."
			return
		end

		# Ensure duration makes sense.
		if params[:duration].to_i <= 0
			redirect_to film_auditions_path(@film), :alert => "Auditions must have a Duration (in minutes) greater than 0."
			return
		end

		# Build (don't save) auditions
		while start < stop do
			@film.auditions.build(:starts_at => start, :location => params[:location])
			start += params[:duration].to_i.minutes
		end

		if @film.save
			redirect_to film_auditions_path(@film), :notice => 'Auditions were successfully created.'
		else
			redirect_to film_auditions_path(@film), :alert => 'Auditions were unable to be created.'
		end
	end

	def create_single
		# Parse date and time inputs into starts_at.
		begin
			starts_at = Time.zone.parse("#{params[:date]} #{params[:time]}")
		rescue
			redirect_to film_auditions_path(@film), :alert => "Invalid date format, please try again."
			return
		end

		# Ensure there are no other times in this time span
		if @film.auditions.where(:starts_at => starts_at).count > 0
			redirect_to film_auditions_path(@film), :alert => "Given audition time conflicts with a pre-existing audition."
			return
		end

		@film.auditions.build(:starts_at => starts_at, :location => params[:location])

		if @film.save
			redirect_to film_auditions_path(@film), :notice => 'Audition was successfully created.'
		else
			redirect_to film_auditions_path(@film), :alert => 'Audition was unable to be created.'
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
