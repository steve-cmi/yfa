class Permission < ActiveRecord::Base	
	belongs_to :film
	belongs_to :person
	
	validates_columns :person_id, :film_id
end
