class EventsController < ApplicationController

  def index
    @scopes = [:day, :week, :month]
    @scope = params[:scope].to_sym || :week

    @filters = Filter.by_position
    @filter = Filter.find_by_slug(params[:filter])

    @dates = EventDate.current.by_date.send("this_#{@scope}")
    @dates = @dates.filtered_by(@filter) if @filter
  end

end
