class CarouselsController < ApplicationController

  before_filter :verify_user

  def index
  end
  
  def new
    @active_nav = :user
    @active_subnav = :carousels
  end
  
  def show
    @active_nav = :user
    @active_subnav = :carousels
    @carousel = Carousel.find(params[:id])
    render :edit
  end
  
  def edit
    @active_nav = :user
    @active_subnav = :carousels
    @carousel = Carousel.find(params[:id])
  end
  
  def create
    @carousel = Carousel.new
    if @carousel.update_attributes(params[:carousel])
      redirect_to admin_carousels_path, :notice => 'Carousel was successfully created.'
    else
      render :new
    end
  end
  
  def update
    @carousel = Carousel.find(params[:id])
    if @carousel.update_attributes(params[:carousel])
      redirect_to admin_carousels_path, :notice => 'Carousel was successfully updated.'
    else
      render :edit
    end
  end

  def update_all
    Site.last.update_attributes(params[:site])
    Carousel.update params[:carousels].keys, params[:carousels].values
    redirect_to admin_carousels_path, :notice => 'Carousels were successfully updated.'
  end
  
  def destroy
    @carousel = Carousel.find(params[:id]) rescue nil
    @carousel.destroy if @carousel
    redirect_to admin_carousels_path, :notice => 'Carousel was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path if(!@current_user || !@current_user.site_admin?)
  end

end
