class GenresController < ApplicationController

  before_filter :force_admin

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
      redirect_to admin_films_path, :alert => "Genre was not able to be created: #{@genre.errors.full_messages.to_sentence}"
    end
  end
  
  def update
    @genre = Genre.find(params[:id]) rescue nil
    if @genre and @genre.update_attributes(params[:genre])
      render :json => {:success => true}
    elsif @genre
      render :json => {:success => false, :errors => @genre.errors.full_messages}
    else
      render :json => {:success => false, :errors => "Genre not found"}
    end
  end
  
  def destroy
    @genre = Genre.find(params[:id]) rescue nil
    @genre.destroy if @genre
    redirect_to admin_films_path, :notice => 'Genre was successfully deleted.'
  end
  
  private
  
  def force_admin
    redirect_to root_path unless @current_user and @current_user.site_admin?
  end

end
