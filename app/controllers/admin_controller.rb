class AdminController < ApplicationController  

	before_filter :verify_site_admin
	before_filter :verify_admin_admin, :only => :admins

	def dashboard
		@active_nav = :user
		@active_subnav = :admin
		@page_name = "Admin Dashboard"
		@pending_films = Film.pending.by_date.reverse_order
		@pending_events = Event.pending.by_date.reverse_order
		@pending_takeovers = TakeoverRequest.where(:approved => false)
	end

	def announcements
		@active_nav = :user
		@active_subnav = :announcements
		@announcements = Announcement.unscoped.reverse_order
		@announcement = Announcement.new
	end

	def carousels
		@active_nav = :user
		@active_subnav = :carousels
		@carousels = Carousel.by_position
		@carousel = Carousel.new
		@site = Site.last
	end

	def events
		@active_nav = :user
		@active_subnav = :events
		@events = Event.unscoped.select([:slug, :name]).order(:name)
		@featured_event = Event.featured.last
		@filters = Filter.all
		@buildings = Building.by_name
		@building = Building.new
	end

	def films
		@active_nav = :user
		@active_subnav = :films
		@films = Film.unscoped.select([:slug, :title]).order(:title)
		@positions = Position.all
		@activities = Activity.all
		@genres = Genre.all
	end

	def jobs
		@active_nav = :user
		@active_subnav = :jobs
		@jobs = Job
    @scopes = [:start_date, :end_date, :company, :position, :title]
    @scope = (params[:scope] || @scopes.first).to_sym
    @jobs = @jobs.order(@scope)
    @jobs = @jobs.reverse_order if params[:desc] == '1'
	end

	def pages
		@active_nav = :user
		@active_subnav = :pages
		@menus = [:main, :resources, :howtos]
		@pages = @menus.inject({}) do |hash, menu|
			hash[menu] = Page.where(menu: menu).order(:position)
			hash
		end
	end

	def admins
		@admins = Person.admins.by_first_last
		@users = Person.users.by_first_last
	end
	
	def approve_takeover
		request = TakeoverRequest.find(params[:id])
		if request.fulfill
			redirect_to admin_dashboard_path, :notice => "#{request.person.display_name}'s request granted!"
		else
			redirect_to admin_dashboard_path, :alert => "There was a problem, please try again..."
		end
	end
	
	def reject_takeover
		request = TakeoverRequest.find(params[:id]) rescue nil
		request.destroy if request
		redirect_to admin_dashboard_path, :notice => "Request Removed!"
	end
	
	def approve_film
		@film = Film.unscoped.find(params[:id])
		@film.approved = true
		@film.archive = params[:archive].to_i == 1
		if @film.save
			redirect_to admin_dashboard_path, :notice => "Film approved!"
		else
			redirect_to admin_dashboard_path, :alert => "There was a problem, please try again..."
		end
	end

	def approve_event
		@event = Event.unscoped.find(params[:id])
		@event.approved = true
		if @event.save
			redirect_to admin_dashboard_path, :notice => "Event approved!"
		else
			redirect_to admin_dashboard_path, :alert => "There was a problem, please try again..."
		end
	end

	private
	
	def verify_site_admin
		redirect_to dashboard_path unless @current_user and @current_user.site_admin?
	end
	
	def verify_admin_admin
		redirect_to dashboard_path unless @current_user and @current_user.admin_admin?
	end
	
end