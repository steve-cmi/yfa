class PositionsController < ApplicationController

  before_filter :verify_user

  def index
  end
  
  def new
  end
  
  def show
    @position = Position.find(params[:id])
    render :edit
  end
  
  def edit
    @position = Position.find(params[:id])
  end
  
  def create
    @position = Position.new
    if @position.update_attributes(params[:position])
      redirect_to admin_films_path, :notice => 'Position was successfully created.'
    else
      render :new
    end
  end
  
  def update
    @position = Position.find(params[:id])
    if @position.update_attributes(params[:position])
      render :json => {:success => true}
    else
      render :json => {:success => false, :errors => @position.errors.full_messages}
    end
  end
  
  def destroy
    @position = Position.find(params[:id]) rescue nil
    @position.destroy if @position
    redirect_to admin_films_path, :notice => 'Position was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path if(!@current_user || !@current_user.site_admin?)
  end

end