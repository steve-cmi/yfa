class AdminController < ApplicationController  

	before_filter :verify_user

	def dashboard
		@active_nav = :user
		@active_subnav = :admin
		@page_name = "Admin Dashboard"
		@pending_films = Film.pending
		@pending_takeovers = TakeoverRequest.where(:approved => false)
	end

	def announcements
		@announcements = Announcement.order(:created_at).reverse_order
		@announcement = Announcement.new
	end

	def carousels
		@carousels = Carousel.by_position
		@carousel = Carousel.new
		@site = Site.last
	end

	def films
		@films = Film.unscoped.select([:slug, :title]).order(:title)
		@positions = Position.all
		@activities = Activity.all
		@genres = Genre.all
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

	def email_all
		if params[:films].blank?
			flash[:alert] = 'Please select which films you want to email.'
		elsif params[:positions].blank?
			flash[:alert] = 'Please select which positions you want to email.'
		elsif params[:subject].blank?
			flash[:alert] = 'Please enter a subject for your email.'
		elsif params[:message].blank?
			flash[:alert] = 'Please enter a message to send.'
		else
			recipients = Person.staff_for(params[:films], params[:positions]).pluck(:email).compact
			if recipients.empty?
				flash[:alert] = 'The selected options matched no people!'
			else
				AdminMailer.staff_email(recipients, params[:subject], params[:message]).deliver
				flash[:notice] = "Email sent to #{recipients.size} people."
			end
		end
		redirect_to :action => :dashboard
	end
	
	private
	
	def verify_user
		redirect_to dashboard_path if(!@current_user || !@current_user.site_admin?)
	end
	
end