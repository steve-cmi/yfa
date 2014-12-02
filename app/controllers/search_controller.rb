class SearchController < ApplicationController  

	skip_before_filter :force_auth

	def index

		@tabs = [:people, :projects, :events]
		@tab = (params[:t] || :people).to_sym

		@people = Person.search(:lname_or_fname_or_email_or_year_or_college_or_bio_cont => params[:q]).result
		@projects = Film.search(:title_or_tagline_or_contact_or_description_cont => params[:q]).result
		@event_dates = EventDate.search(:event_name_or_event_location_or_event_description_cont => params[:q]).result.includes(:event).by_date.reverse_order

		# Obtain badge counts before adding refinements
		@badge = {
			:people => @people.count,
			:projects => @projects.count,
			:events => @event_dates.count
		}

		# Add refinements
		case @tab
		when :projects
			@projects = @projects.search(:title_start => params[:title]).result if params[:title]
			@projects = @projects.recent if params[:recent]
		when :events
			@event_dates = @event_dates.current if params[:future]
		end

	end
	
	def lookup
		params[:query] = params[:term] if params[:term]
		
		if params[:type] == "people"
			@results = Person.where("CONCAT_WS( ' ', `fname` , `lname` ) LIKE ?", "%#{params[:query]}%")
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
