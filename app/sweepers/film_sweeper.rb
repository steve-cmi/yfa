class FilmSweeper < ActionController::Caching::Sweeper
  observe Film # This sweeper is going to keep an eye on the Film model
 
  # If our sweeper detects that a film was created call this
  def after_create(film)
    expire_cache_for(film)
  end
 
  # If our sweeper detects that a film was updated call this
  def after_update(film)
    expire_cache_for(film)
  end
 
  # If our sweeper detects that a film was deleted call this
  def after_destroy(film)
    expire_cache_for(film)
  end

  private
  def expire_cache_for(film)
    return unless (film.changed & ['title','writer','location','poster']).length > 0
    expire_fragment(:controller => "films", 
                :action => "index", 
                :action_suffix => film.semester)
  end
end