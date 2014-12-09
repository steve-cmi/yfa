class Screening < ActiveRecord::Base	
	belongs_to :film
  belongs_to :building

	def self.by_date
		order(:starts_at)
	end
	
	def self.current
		where('starts_at >= CURRENT_TIMESTAMP')
	end
	
	def self.past
		where('starts_at < CURRENT_TIMESTAMP')
	end
	
	def current?
		self.starts_at > Time.zone.now
	end

	def past?
		self.starts_at < Time.zone.now
	end
	
end
