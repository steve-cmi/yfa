class SearchController < ApplicationController  

	skip_before_filter :force_auth
	skip_before_filter :force_user

	def index

		@tabs = [:people, :projects, :events]
		@tab = (params[:t] || :people).to_sym
		@page_name = "Search #{@tab.to_s.titlecase}"

		@people = Person.search(:lname_or_fname_or_email_or_year_or_college_or_bio_cont => params[:q]).
			result.by_first_last
		@projects = Film.search(:title_or_tagline_or_contact_or_description_cont => params[:q]).
			result.by_title
		@event_dates = EventDate.search(:event_name_or_event_location_or_event_description_cont => params[:q]).
			result.includes(:event => [:filters, :building]).approved.by_date.reverse_order

		# Obtain badge counts before adding refinements
		@badge = {
			:people => @people.count,
			:projects => @projects.count,
			:events => @event_dates.count
		}

		# Add refinements
		case @tab
		when :people
			@years = Person.uniq.order(:year).pluck(:year).reject(&:blank?)
			@positions = Position.all.collect {|p| [p.position, p.id]}
			@people = @people.search(:lname_or_fname_start => params[:name]).result unless params[:name].blank?
			@people = @people.current if params[:current]
			@people = @people.where(:year => params[:year]) unless params[:year].blank?
			@people = @people.with_position(params[:position]) unless params[:position].blank?
		when :projects
			@projects = @projects.search(:title_start => params[:title]).result unless params[:title].blank?
			@projects = @projects.recent if params[:recent]
		when :events
			@event_dates = @event_dates.current if params[:future]
		end

	end
	
	def lookup
		params[:query] = params[:term] if params[:term]
		
		if params[:type] == "people"
			@results = Person.autocomplete(params[:query])
			respond_to do |format|
		    format.html { render :action => "results" }
		    format.json { render :json => @results.to_json(:only => [:id,:fname,:lname,:college,:year]) }
		  end
		elsif params[:type] == "film"
		 	@results = Film.where("title LIKE ?", "%#{params[:query]}%")
			respond_to do |format|
		    format.html { render :action => "results" }
		    format.json { render :json => @results }
		  end
		end
  end
end
