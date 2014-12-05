class Position < ActiveRecord::Base	
	has_many :film_positions, :dependent => :delete_all
	has_many :people, :through => :film_positions

  validates :position, :presence => true
  validates :position, :uniqueness => true

  # Instead of identifying positions by ID or name, which can change,
  # we have added a "key" column. This is intended to act as a marker
  # which defines the meaning of a position without requiring it to
  # have a specific ID or display name. We can now use these to cleanly
  # find a film's actors, writers, directors, cast, and crew.

  def actor?
    id == self.class.actor_id
  end

  def writer?
    id == self.class.writer_id
  end

  def director?
    id == self.class.director_id
  end

  def self.actor_id
    @@actor_id ||= id_for_key(:actor)
  end

  def self.writer_id
    @@writer_id ||= id_for_key(:writer)
  end

  def self.director_id
    @@director_id ||= id_for_key(:director)
  end

  def self.id_for_key(key)
    where(key: key.to_s).select(:id).first.id
  end

  def self.crew
    where('id != ?', actor_id)
  end

end
