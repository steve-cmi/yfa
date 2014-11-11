class ShowtimesController < ApplicationController  
	
	before_filter :fetch_show
	
	def index
	end
	
	def show
		@showtime = @show.showtimes.find(params[:id])
	end

	private
	
	def fetch_show
		@show = Show.find(params[:show_id]) if(params[:show_id])
		@show ||= Show.find_by_url_key(params[:url_key]) if(params[:url_key])
		render :not_found if(!@show)
	end
	
end