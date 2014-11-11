class ShowtimesController < ApplicationController  
	
	before_filter :fetch_film
	
	def index
	end
	
	def show
		@showtime = @film.showtimes.find(params[:id])
	end

	private
	
	def fetch_film
		@film = Film.find(params[:show_id]) if params[:show_id]
		@film ||= Film.find_by_url_key(params[:url_key]) if params[:url_key]
		render :not_found unless @film
	end
	
end