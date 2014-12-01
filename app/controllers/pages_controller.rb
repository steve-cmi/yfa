class PagesController < ApplicationController
	skip_before_filter :force_auth
	
	# The page users hit when they first visit in browser.
	def index
		@active_nav = :home
		@site = Site.last
		@carousels = Carousel.active.order_by(@site)
		@upcoming_films = Film.by_date.limit(5)
		@announcement = Announcement.last
		@featured_event = EventDate.current.featured.by_date.first
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

	def donate
		@page_name = 'Donate'
		@active_nav = :donate
	end

end
