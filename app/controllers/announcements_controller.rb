class AnnouncementsController < ApplicationController  

	before_filter :verify_user

	def index
	end
	
	def new
		@active_nav = :user
		@active_subnav = :announcements
	end
	
	def show
		@active_nav = :user
		@active_subnav = :announcements
		@announcement = Announcement.find(params[:id])
		render :edit
	end
	
	def edit
		@active_nav = :user
		@active_subnav = :announcements
		@announcement = Announcement.find(params[:id])
		@announcement = Announcement.find(params[:id])
	end
	
	def create
		@announcement = Announcement.new
		if @announcement.update_attributes(params[:announcement])
			redirect_to admin_announcements_path, :notice => 'Announcement was successfully created.'
		else
			render :new
		end
	end
	
	def update
		@announcement = Announcement.find(params[:id])
    if @announcement.update_attributes(params[:announcement])
      redirect_to admin_announcements_path, :notice => 'Announcement was successfully updated.'
    else
    	render :edit
    end
	end

  def update_all
    Announcement.update params[:announcements].keys, params[:announcements].values
    redirect_to admin_announcements_path, :notice => 'Announcements were successfully updated.'
  end
	
	def destroy
		@announcement = Announcement.find(params[:id]) rescue nil
		@announcement.destroy if @announcement
		redirect_to admin_announcements_path, :notice => 'Announcement was successfully deleted.'
	end
	
	private
	
	def verify_user
		redirect_to root_path if(!@current_user || !@current_user.site_admin?)
	end
	
end
