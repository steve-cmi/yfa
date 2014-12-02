class Permission < ActiveRecord::Base	
	belongs_to :film
	belongs_to :person
end
