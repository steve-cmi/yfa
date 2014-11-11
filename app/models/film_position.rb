class FilmPosition < ActiveRecord::Base
	belongs_to :film
	belongs_to :person
	belongs_to :position
	after_create :recache_director
	after_update :recache_director
	after_update :cleanup_person, :if => proc {|sp| sp.person_id_was != sp.person_id }
	after_destroy :recache_director
	after_destroy :cleanup_person
	
	validates :person, :character, :presence => true, :if => Proc.new { |sp| sp.position_id == 17 }
	
	scope :vacant, where(:person_id => nil)
	scope :not_vacant, where("person_id IS NOT NULL && person_id != 0")
	scope :crew, where("position_id != 17")
	scope :cast, where("position_id = 17")
	
	default_scope :order => "listing_order ASC, assistant ASC, position_id ASC"
	
	def display_name
		if self.cast?
			self.character
		else
			self.assistant ? "#{self.assistant.to_s.capitalize} #{self.position.display_name}" : self.position.display_name
		end
	end
	
	def cast?
		self.position_id == 17
	end
	
	private
	
	def recache_director
		self.film.bust_director_cache if (self.position_id == 1 || self.position_id_was == 1) && self.film
	end
	
	# TODO: verify this does what it's supposed to
	def cleanup_old_person
		self.person_was.destroy if self.person_was && self.person_was.film_positions.count == 0 && self.person_was.netid.blank?
	end
	
	def cleanup_person
		self.person.destroy if self.person && self.person.film_positions.count == 0 && self.person.netid.blank?
	end

	#### New code added by steve@commonmedia.com March 2013.

	# Select positions for admin email_all
	def self.primary
		where('assistant IS NULL')
	end

	def self.producers
		where(:position_id => 1)
	end

	def self.contacts
		where(:position_id => [1,2,3])
	end
	
	####
	
end