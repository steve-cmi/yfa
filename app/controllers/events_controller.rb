class EventsController < ApplicationController

  skip_before_filter :force_auth, :only => :index
  before_filter :fetch_event, :except => [:index, :new, :create]

  def index
    @page_name = "Calendar"
    
    @scopes = [:day, :week, :month]
    @scope = (params[:scope] || :week).to_sym

    @filters = Filter.by_position
    @filter = Filter.find_by_slug(params[:filter])

    @dates = EventDate.current.by_date.includes(:event => [:building, :filters]).send("this_#{@scope}")
    @dates = @dates.filtered_by(@filter) if @filter
  end

  def show
    @active_nav = :events
    @page_name = @event.title
  end

  def new
    @active_nav = :user
    @active_subnav = :events
    @event = @current_user.events.build
    @page_name = 'New Event'
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
    @page_name = "Edit Event - #{@event.title}"
  end

  def update
    respond_to do |format|
      if @event.update_attributes(params[:event])

        # Tell the EventMailer to send an approval Email to the admin after save
        EventMailer.need_approval_email(@event).deliver if params[:id].blank?

        format.html do 
          if params[:id].blank?
            redirect_to(event_edit_people_path(@event))
          else
            redirect_to(event_dashboard_path(@event), :notice => 'Event was successfully updated.')
          end
        end
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
    redirect_to admin_dashboard_path
  end

  private
  
  def fetch_event
    event_id = params[:event_id] || params[:id]
    @event = Event.unscoped.includes(:event_positions => [:person, :position]).find(event_id) if event_id
    raise ActionController::RoutingError.new('Not Found') unless @event && (@event.approved || @current_user.has_permission?(@event))
  end
end
