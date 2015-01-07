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
      redirect_to admin_films_path, :alert => "Position was not able to be created: #{@position.errors.full_messages.to_sentence}"
    end
  end
  
  def update
    @position = Position.find(params[:id]) rescue nil
    if @position and @position.update_attributes(params[:position])
      render :json => {:success => true}
    elsif @position
      render :json => {:success => false, :errors => @position.errors.full_messages}
    else
      render :json => {:success => false, :errors => "Position not found"}
    end
  end
  
  def destroy
    @position = Position.find(params[:id]) rescue nil
    @position.destroy if @position
    redirect_to admin_films_path, :notice => 'Position was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path unless @current_user and @current_user.site_admin?
  end

end
