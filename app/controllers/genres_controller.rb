class GenresController < ApplicationController

  before_filter :verify_user

  def index
  end
  
  def new
  end
  
  def show
    @genre = Genre.find(params[:id])
    render :edit
  end
  
  def edit
    @genre = Genre.find(params[:id])
  end
  
  def create
    @genre = Genre.new
    if @genre.update_attributes(params[:genre])
      redirect_to admin_films_path, :notice => 'Genre was successfully created.'
    else
      render :new
    end
  end
  
  def update
    @genre = Genre.find(params[:id])
    if @genre.update_attributes(params[:genre])
      render :json => {:success => true}
    else
      render :json => {:success => false, :errors => @genre.errors.full_messages}
    end
  end
  
  def destroy
    @genre = Genre.find(params[:id]) rescue nil
    @genre.destroy if @genre
    redirect_to admin_films_path, :notice => 'Genre was successfully deleted.'
  end
  
  private
  
  def verify_user
    redirect_to root_path if(!@current_user || !@current_user.site_admin?)
  end

end
