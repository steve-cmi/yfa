class FiltersController < ApplicationController

  before_filter :verify_user

  def index
  end
  
  def new
  end
  
  def show
    @filter = Filter.find(params[:id])
    render :edit
  end
  
  def edit
    @filter = Filter.find(params[:id])
  end
  
  def create
    @filter = Filter.new
    if @filter.update_attributes(params[:filter])
      redirect_to admin_events_path, :notice => 'Filter was successfully created.'
    else
      redirect_to admin_films_path, :alert => "Filter was not able to be created: #{@filter.errors.full_messages.to_sentence}"
    end
  end
  
  def update
    @filter = Filter.find(params[:id]) rescue nil
    if @filter and @filter.update_attributes(params[:filter])
      render :json => {:success => true}
    elsif @filter
      render :json => {:success => false, :errors => @filter.errors.full_messages}
    else
      render :json => {:success => false, :errors => "Filter not found"}
    end
  end
  
  def destroy
    @filter = Filter.find(params[:id]) rescue nil
    @filter.destroy if @filter
    redirect_to admin_events_path, :notice => 'Filter was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path unless @current_user and @current_user.site_admin?
  end

end
