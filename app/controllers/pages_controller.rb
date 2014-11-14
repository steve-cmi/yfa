class PagesController < ApplicationController
	skip_before_filter :force_auth
	
	# The page users hit when they first visit in browser.
	def index
		@active_nav = :home
		@site = Site.last
		@carousels = Carousel.active.order_by(@site)
		@upcoming_films = Film.by_date
		@announcement = Announcement.last
	end

	# Static Pages
	def resources
		@page_name = 'Resources'
		@active_nav = :resources
	end

	def donate
		@page_name = 'Donate'
		@active_nav = :donate
	end

end