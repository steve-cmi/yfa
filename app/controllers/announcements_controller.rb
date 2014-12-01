class AnnouncementsController < ApplicationController  

	before_filter :verify_user

	# TODO: Maybe eventually build this out?
	def index
	end
	
	# TODO: Maybe let people submit announcement items?
	def new
	end
	
	def show
		@announcement = Announcement.find(params[:id])
		render :edit
	end
	
	def edit
		@announcement = Announcement.find(params[:id])
	end
	
	def create
		@announcement = Announcement.new
		if @announcement.update_attributes(params[:announcement])
			redirect_to admin_dashboard_path, :notice => 'Announcement was successfully created.'
		else
			redirect_to admin_dashboard_path, :notice => 'Sorry, there was a problem with the data you entered, please try again'
		end
	end
	
	def update
		@announcement = Announcement.find(params[:id])
		respond_to do |format|
	    if @announcement.update_attributes(params[:announcement])
	      format.html { redirect_to admin_dashboard_path, :notice => 'Announcement was updated.' }
	      format.json { respond_with_bip(@announcement) }
	    else
	    	flash.now[:alert] = 'Sorry, there was a problem with the data you entered, please try again'
	      format.html { render :action => "edit" }
	      format.json { respond_with_bip(@announcement) }
	    end
	  end
	end
	
	def destroy
		@announcement = Announcement.find(params[:id]) rescue nil
		@announcement.destroy if @announcement
		redirect_to admin_dashboard_path, :notice => 'Announcement deleted.'
	end
	
	private
	
	def verify_user
		redirect_to root_path if(!@current_user || !@current_user.site_admin?)
	end
	
end