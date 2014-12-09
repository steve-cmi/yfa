class AdminController < ApplicationController  

	before_filter :verify_user

	def dashboard
		@active_nav = :user
		@active_subnav = :admin
		@page_name = "Admin Dashboard"
		@pending_films = Film.pending
		@pending_events = Event.pending
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
		@jobs = Job.by_date.reverse_order
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

	def newsletter
		@films = Film.readonly.this_week
		@auditions = Audition.future.includes(:film).select{|a| a.film}.group_by(&:film)
		future_film_ids = Film.future.pluck("`films`.`id`")
		@opportunities = FilmPosition.crew.vacant.where(:film_id => future_film_ids).includes(:film, :position).group_by(&:film)
		@opportunities = @opportunities.select{|film, arr| film.open_date >= Time.now + 11.days && film.open_date <= Time.now + 60.days}.sort_by{|s,arr| s.open_date}
		@request = request

		@announcements = params[:subject] && params[:message] ? params[:subject].zip(params[:message]) : []
		@preview = true
		if params[:send]
			NewsletterMailer.newsletter_email(@films, @auditions, @announcements, @opportunities, request).deliver
			redirect_to admin_dashboard_path, :notice => "Email sent"
		else
			render :file => 'newsletter_mailer/newsletter_email.html.erb', :layout => false
		end
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
	
	def verify_user
		redirect_to dashboard_path unless @current_user and @current_user.site_admin?
	end
	
end