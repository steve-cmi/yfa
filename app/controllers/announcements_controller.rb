class AnnouncementsController < ApplicationController  

	before_filter :force_admin

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
	
	def force_admin
		redirect_to root_path unless @current_user and @current_user.site_admin?
	end
	
end
