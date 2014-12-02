class ScreeningsController < ApplicationController  
	
	before_filter :fetch_film
	
	def index
	end
	
	def show
		@screening = @film.screenings.find(params[:id])
	end

	private
	
	def fetch_film
		@film = Film.find(params[:film_id]) if params[:film_id]
		render :not_found unless @film
	end
	
end