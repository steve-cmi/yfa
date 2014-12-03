class EventsController < ApplicationController

  def index
    @page_name = "Calendar"
    
    @scopes = [:day, :week, :month]
    @scope = (params[:scope] || :week).to_sym

    @filters = Filter.by_position
    @filter = Filter.find_by_slug(params[:filter])

    @dates = EventDate.current.by_date.includes(:event => [:building, :filters]).send("this_#{@scope}")
    @dates = @dates.filtered_by(@filter) if @filter
  end

end
