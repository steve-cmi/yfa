class Position < ActiveRecord::Base	
	has_many :film_positions
	has_many :people, :through => :film_positions
	
	def display_name
		self.position
	end
end