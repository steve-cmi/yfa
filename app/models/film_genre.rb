class FilmGenre < ActiveRecord::Base

  belongs_to :film
  belongs_to :genre

  validates :genre_id, :uniqueness => {:scope => :film_id, :message => "has already been assigned to this film"}

end