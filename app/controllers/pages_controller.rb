class PagesController < ApplicationController
	skip_before_filter :force_auth
	
	# The page users hit when they first visit in browser.
	def index
		@active_nav = :home

		# flash.now[:notice] = "NOTICE"
		# flash.now[:error] = "ERROR"

	end

	# Static Pages
	def resources
		@page_name = " - Resources"
		@active_nav = :resources
	end

	def donate
		@page_name = " - Donate"
		@active_nav = :donate
	end

	# The parameter we recieve is the file that we want to render
	def guides
		# TODO: SHould probably NOINDEX these, or find a better way to get the data out and into the template
		#Be careful with this as it could lead to bad things
		@page_name = " - Resources"
		@active_nav = :resources
		@file = params[:static_file] + ".html"
		raise ActiveRecord::RecordNotFound unless params[:static_file] =~ /\A[\w\-]+\Z/ && FileTest.exists?(Rails.root + "public/static_guides/" + @file)
	end

end