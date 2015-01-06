class ActivitiesController < ApplicationController

  before_filter :verify_user

  def index
  end
  
  def new
  end
  
  def show
    @activity = Activity.find(params[:id])
    render :edit
  end
  
  def edit
    @activity = Activity.find(params[:id])
  end
  
  def create
    @activity = Activity.new
    if @activity.update_attributes(params[:activity])
      redirect_to admin_films_path, :notice => 'Activity was successfully created.'
    else
      redirect_to admin_films_path, :alert => "Activity was not able to be created: #{@activity.errors.full_messages.to_sentence}"
    end
  end
  
  def update
    @activity = Activity.find(params[:id])
    if @activity.update_attributes(params[:activity])
      render :json => {:success => true}
    else
      render :json => {:success => false, :errors => @activity.errors.full_messages}
    end
  end
  
  def destroy
    @activity = Activity.find(params[:id]) rescue nil
    @activity.destroy if @activity
    redirect_to admin_films_path, :notice => 'Activity was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path unless @current_user and @current_user.site_admin?
  end

end
