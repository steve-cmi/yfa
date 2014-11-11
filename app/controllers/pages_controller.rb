class PagesController < ApplicationController
	skip_before_filter :force_auth
	
	# The page users hit when they first visit in browser.
	def index
		# Select and load active modules from config DB (if any)
		@active_nav = :home

		# Load in news posts and other relevant content for display
		@news = News.order("created_at DESC").first(5)

		@modules = []
		@rows = []
		# Films!
		# TODO: Change this, duh!

		# Group things appropriately. Cannot be more than 2 modules
		@films = Film.readonly.coming_soon.this_week

		@showtime_data = {}
		@films.each {|film| @showtime_data[film.id] = film.showtimes.map {|st| {:id => st.id, :text => st.short_display_time, :cap => film.cap}}}

		# TODO: Algorithmically re-arrange posters to be in rows of 2

		puts "Condensing #{@films.length} films and #{@modules.length} modules"

		if @films.length + @modules.length <= 3
			@rows = [@films + @modules]
		elsif @films.length + @modules.length == 4
			@rows = [@films.slice!(0,2), @films + @modules]	# 2 films / 2 films/modules
		elsif @films.length + @modules.length == 5
			@rows = [@films.slice!(0,2), @films + @modules]	# 2 films / 3 films/modules
		elsif @films.length + @modules.length == 6
			@rows = [@films.slice!(0,3), @films + @modules] # 3 films / 3 films/modules
		elsif @films.length + @modules.length == 7
			if @modules.length >= 1
				@rows = [ @films.slice!(0,2), @films.slice!(0,2) + @modules.slice!(0,1), @films + @modules] # 2 films / 3 films(most one module) / 2 films/modules
			else
				@rows = [ @films.slice!(0,2), @films.slice!(0,3), @films.slice!(0,2) ] # 2 films / 3 films(most one module) / 2 films/modules
			end
		elsif @films.length + @modules.length == 8	# 3 films/modules / 2 films / 3 modules/films
			if @modules.length >= 2
				@rows = [ @films.slice!(0,2) + @modules.slice!(0,1), @films.slice!(0,2), @films + @modules]
			else
				@rows = [ @films.slice!(0,3), @films.slice!(0,2), @films + @modules]
			end
		else
			#more than 8? Pshew. Good luck
			while @films.length > 0
				@rows += [@films.slice!(0,2 + @rows.length % 2)]
			end
		end

		puts "row config: #{@rows.map{|r| r.length}.inspect}"
	end

	# Static Pages
	def resources
		@page_name = " - Resources"
		@active_nav = :learn
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
		@active_nav = :learn
		@file = params[:static_file] + ".html"
		raise ActiveRecord::RecordNotFound unless params[:static_file] =~ /\A[\w\-]+\Z/ && FileTest.exists?(Rails.root + "public/static_guides/" + @file)
	end

end