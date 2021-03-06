# Sorry, this controller is the messiest. It's bad

class AuditionsController < ApplicationController

	before_filter :fetch_film, :except => [:cast, :crew]

	# Cast Opportunities
	def cast
		@page_name = "Student Productions - Cast"
		@active_nav = :opportunities
		@active_subnav = :auditions
		@scopes = [:crew, :cast]
		@scope = :cast
		@films = Film.current.has_auditions.includes(:auditions, :director)
	end

	# Crew Opportunities
	def crew
		@page_name = "Student Productions - Crew"
		@active_nav = :opportunities
		@active_subnav = :auditions
		@scopes = [:crew, :cast]
		@scope = :crew
		@film_positions = FilmPosition.unscoped.current.crew.vacant.includes(:film, :position).by_name
		@film_positions = @film_positions.filtered_by(params[:positions]) if params[:positions]
		@positions = Position.crew.by_name.all
	end

	def index
		@page_name = "Auditions - #{@film.title}"
		@active_nav = :opportunities
		@active_subnav = :auditions
		@auditions = [] and return if request.format == :csv && !@current_user.has_permission?(@film)

		@auditions = @film.auditions.current
		redirect_to '/auditions' if @auditions.none? && !@current_user.has_permission?(@film)

		@user_audition = @auditions.find_by_person_id(@current_user.id)
		@recent_auditions = @film.auditions.recent

		send_data @auditions.to_csv, type: :csv, filename: 'auditions.csv' if params[:format] == 'csv'
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
		if !@aud_admin
			redirect_to :back, :notice => 'You do not have permission to create auditions.'
		elsif params[:multiple] == 'true'
			logger.debug "Create multiple"
			create_multiple
		else
			logger.debug "Create single"
			create_single
		end
	end

	def create_multiple
		# Parse date and time inputs into start and stop.
		begin
			start = Time.zone.parse("#{params[:date]} #{params[:start_time]}")
			stop = Time.zone.parse("#{params[:date]} #{params[:end_time]}")
		rescue
			redirect_to :back, :alert => "Invalid date format, please try again."
			return
		end

		# Ensure there are no other times in this time span
		if @film.auditions.where(:starts_at => (start...stop)).count > 0
			redirect_to :back, :alert => "Given audition times conflict with pre-existing auditions."
			return
		end

		# Ensure duration makes sense.
		if params[:duration].to_i <= 0
			redirect_to :back, :alert => "Auditions must have a Duration (in minutes) greater than 0."
			return
		end

		# Build (don't save) auditions
		while start < stop do
			@film.auditions.build(:starts_at => start, :location => params[:location])
			start += params[:duration].to_i.minutes
		end

		if @film.save
			redirect_to :back, :notice => 'Auditions were successfully created.'
		else
			redirect_to :back, :alert => 'Auditions were unable to be created.'
		end
	end

	def create_single
		# Parse date and time inputs into starts_at.
		begin
			starts_at = Time.zone.parse("#{params[:date]} #{params[:time]}")
		rescue
			redirect_to :back, :alert => "Invalid date format, please try again."
			return
		end

		# Ensure there are no other times in this time span
		if @film.auditions.where(:starts_at => starts_at).count > 0
			redirect_to :back, :alert => "Given audition time conflicts with a pre-existing audition."
			return
		end

		@film.auditions.build(:starts_at => starts_at, :location => params[:location])

		if @film.save
			redirect_to :back, :notice => 'Audition was successfully created.'
		else
			redirect_to :back, :alert => 'Audition was unable to be created.'
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

			redirect_to film_auditions_path(@film), :notice => 'Audition successfully updated.'

		elsif params[:destroy_ids] || params[:auditions]

			raise unless @aud_admin
			destroy_ids = params[:destroy_ids] || params[:auditions].collect {|id, values| id if values[:_destroy] == "1"}.compact
			@film.auditions.destroy(*destroy_ids) unless destroy_ids.empty?

			respond_to do |format|
				format.js
				format.html {
					redirect_to film_auditions_path(@film), :notice => 'Audition successfully updated.'
				}
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

		end
	end

	private

	def fetch_film
		# Fim id is sometimes film_id
		film_id = params[:film_id] || params[:id]

		# Check permissions, if admin, pre-load the people too
		if logged_in? && @current_user.has_permission?(film_id)
			@aud_admin = true
			@film = Film.includes(:auditions => :person).find(film_id)
		else
			@film = Film.includes(:auditions).find(film_id)
		end
	end
end
