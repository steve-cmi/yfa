class EventsController < ApplicationController

  skip_before_filter :force_auth, :only => :index
  skip_before_filter :force_user, :only => :index
  before_filter :fetch_event, :except => [:index, :new, :create]

  def index
    @page_name = "Calendar"
    
    @scopes = [:day, :week, :month]
    @scope = (params[:scope] || :week).to_sym

    @filters = Filter.by_position.collect {|f| [f.name, f.slug]}
    @filter = Filter.find_by_slug(params[:filter])
    @screenings = Filter.find_by_slug('screenings')

    @date = Date.parse(params[:date]) rescue nil
    @date ||= Date.today

    @next_date = @date.send("next_#{@scope}")
    @prev_date = @date.send("prev_#{@scope}")

    @dates = EventDate.approved.by_date.includes(:event => [:building, :filters]).send("#{@scope}_of", @date)
    @dates = @dates.filtered_by(@filter) if @filter

    if @filter.nil? or @filter == @screenings
      @dates += Screening.approved.by_date.includes(:film, :building).send("#{@scope}_of", @date)
      @dates = @dates.sort_by(&:starts_at) if @filter.blank?
    end
    
  end

  def new
    @active_nav = :user
    @active_subnav = :events
    @event = @current_user.events.build
    @page_name = 'New Event'
    @buildings = Building.all
    render :edit
  end
  
  def create
    @event = @current_user.events.build
    @event.approved = false
    update
  end
  
  def edit
    @active_nav = :user
    @active_subnav = :events
    @page_name = "Edit Event - #{@event.name}"
    @buildings = Building.all
  end

  def set_featured
    Event.unscoped.update_all 'featured = false'
    if @event and @event.update_attribute(:featured, true)
      redirect_to admin_events_path, :notice => 'Featured Event was successfully set.'
    else
      redirect_to admin_events_path, :alert => 'Featured Event was unable to be set.'
    end
  end

  def update
    # Process event_dates
    if params[:event][:event_dates_attributes]
      params[:event][:event_dates_attributes].each do |key, obj| 
        # Merge date and time strings into a starts_at datetime.
        obj[:starts_at] = Time.zone.parse("#{obj.delete(:date)} #{obj.delete(:time)}") rescue nil

        # Remove it if it doesn't have the needed fields
        if obj[:starts_at].blank?
          params[:event][:event_dates_attributes].delete(key) 
          next
        end
      end
    end

    respond_to do |format|
      if @event.update_attributes(params[:event])

        # Tell the EventMailer to send an approval Email to the admin after save
        EventMailer.need_approval_email(@event).deliver if params[:id].blank?

        format.html { redirect_to(dashboard_path, :notice => 'Event was successfully updated.') }
        format.json { render :json => {:success => true} }
        format.js { render :nothing => true }
      else
        format.html { render :action => "edit" }
        format.json { render :json => {:error => true} }
        format.js { render :nothing => true }
      end
    end
  end
  
  def destroy
    @event.destroy
    # Admin dash will redirect normal people to user dash
    redirect_to admin_events_path
  end

  private
  
  def fetch_event
    event_id = params[:event_id] || params[:id]
    @event = Event.unscoped.includes(:event_dates, :event_filters).find(event_id) rescue nil if event_id
    raise ActionController::RoutingError.new('Not Found') unless @current_user.site_admin? || (@event && @event.approved && @event.person == @current_user)
  end
end
