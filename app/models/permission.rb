class Permission < ActiveRecord::Base	
	belongs_to :film
	belongs_to :person
	
	validates_columns :level, :person_id, :film_id
	attr_accessible :level, :person_id, :film_id
end