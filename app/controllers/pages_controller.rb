class PagesController < ApplicationController

	skip_before_filter :force_auth

	# The page users hit when they first visit in browser.
	def index
		@active_nav = :home
		@site = Site.last
		@carousels = Carousel.active.order_by(@site)
		@upcoming_films = Film.by_date.includes(:director).limit(5)
		@announcement = Announcement.active.last
		@featured_event = Event.featured.last
    @featured_event_date = @featured_event.featured_date if @featured_event
	end

	# Dynamic pages from the pages table
	def show
		@page = Page.find params[:id]
		@page_name = @page.title
		case @page.menu.to_sym
		when :resources
			@active_nav = :resources
		when :howtos
			@active_nav = :resources
			@active_subnav = :howtos
		end
	end

	# Static Pages
	def howtos
		@page_name = 'How To\'s'
		@active_nav = :resources
		@active_subnav = :howtos
	end

	##### Administrator access
  before_filter :verify_user, :only => [:new, :edit, :create, :update, :update_all, :destroy]

  def new
    @active_nav = :user
    @active_subnav = :pages
    @page = Page.new menu: params[:menu]
  end
  
  def edit
    @active_nav = :user
    @active_subnav = :pages
    @page = Page.find(params[:id])
  end
  
  def create
    @page = Page.new
    if @page.update_attributes(params[:page])
      redirect_to admin_pages_path, :notice => 'Page was successfully created.'
    else
      render :new
    end
  end
  
  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(params[:page])
      redirect_to admin_pages_path, :notice => 'Page was successfully updated.'
    else
      render :edit
    end
  end

  def update_all
    Page.update params[:pages].keys, params[:pages].values
    redirect_to admin_pages_path, :notice => 'Pages were successfully updated.'
  end
  
  def destroy
    @page = Page.find(params[:id]) rescue nil
    @page.destroy if @page
    redirect_to admin_pages_path, :notice => 'Page was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path unless @current_user and @current_user.site_admin?
  end

end
