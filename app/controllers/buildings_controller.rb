class BuildingsController < ApplicationController

  before_filter :verify_user

  def index
  end
  
  def new
    @active_nav = :user
    @active_subnav = :buildings
  end
  
  def show
    @active_nav = :user
    @active_subnav = :buildings
    @building = Building.find(params[:id])
    render :edit
  end
  
  def edit
    @active_nav = :user
    @active_subnav = :buildings
    @building = Building.find(params[:id])
  end
  
  def create
    @building = Building.new
    if @building.update_attributes(params[:building])
      redirect_to admin_buildings_path, :notice => 'Building was successfully created.'
    else
      render :new
    end
  end
  
  def update
    @building = Building.find(params[:id])
    if @building.update_attributes(params[:building])
      redirect_to admin_buildings_path, :notice => 'Building was successfully updated.'
    else
      render :edit
    end
  end

  def update_all
    Building.update params[:buildings].keys, params[:buildings].values
    redirect_to admin_buildings_path, :notice => 'Buildings were successfully updated.'
  end
  
  def destroy
    @building = Building.find(params[:id]) rescue nil
    @building.destroy if @building
    redirect_to admin_buildings_path, :notice => 'Building was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path if(!@current_user || !@current_user.site_admin?)
  end

end
