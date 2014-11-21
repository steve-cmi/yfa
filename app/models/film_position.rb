class FilmPosition < ActiveRecord::Base

	belongs_to :film
	belongs_to :person
	belongs_to :position

	acts_as_list :column => :listing_order, :scope => :film

	after_update :cleanup_person, :if => proc {|sp| sp.person_id_was != sp.person_id }
	after_destroy :cleanup_person

	scope :directors, where(:position_id => Position.director_id)
	scope :actors, where(:position_id => Position.actor_id)
	scope :writers, where(:position_id => Position.writer_id)
	
	scope :crew, where(arel_table[:position_id].not_eq(Position.actor_id))
	scope :cast, actors()
	scope :filled, where("person_id IS NOT NULL AND person_id != 0")
	scope :vacant, where("person_id IS NULL OR person_id = 0")
	scope :with_character, where("`character` IS NOT NULL AND `character` != ''")
	scope :without_character, where("`character` IS NULL OR `character` = ''")

	default_scope :order => "listing_order ASC, position_id ASC"
	
	validates :person, :character, :presence => true, :if => :cast?
	
	def cast?
		position_id == 1
	end
	
	def crew?
		position_id != 1
	end
	
	def display_name
		cast? ? character : position.position
	end
	
	private
	
	# TODO: verify this does what it's supposed to
	def cleanup_old_person
		person_was.destroy if person_was && person_was.film_positions.count == 0 && person_was.netid.blank?
	end
	
	def cleanup_person
		person.destroy if person && person.film_positions.count == 0 && person.netid.blank?
	end
	
end