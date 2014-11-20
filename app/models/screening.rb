class Screening < ActiveRecord::Base	
	belongs_to :film
	
	after_create :notify_oup
	after_update :notify_oup

	def notify_oup
		return unless self.timestamp_changed?
		@film = self.film rescue nil # will error if film can't be found, meaning not approved
		ScreeningMailer.notify_oup_email(@film,self).deliver if @film && @film.approved		
	end
	
	def self.future
		where('timestamp >= CURRENT_TIMESTAMP')
	end
	
	def self.this_semester
		where('timestamp BETWEEN ? AND ?', Yale::semester_start, Yale::semester_end)
	end

	def self.this_year
		where('timestamp BETWEEN ? AND ?', Yale::year_start, Yale::year_end)
	end

	def self.upcoming
		self.future
	end

	def future?
		self.timestamp > Time.zone.now
	end

	def past?
		self.timestamp < Time.zone.now
	end
	
end
