class Screening < ActiveRecord::Base	
	belongs_to :film
  belongs_to :building

	# Does YFA want this?
	# after_create :notify_oup
	# after_update :notify_oup

	# def notify_oup
	# 	return unless self.timestamp_changed?
	# 	@film = self.film rescue nil # will error if film can't be found, meaning not approved
	# 	ScreeningMailer.notify_oup_email(@film,self).deliver if @film && @film.approved		
	# end
	
	def self.current
		where('timestamp >= CURRENT_TIMESTAMP')
	end
	
	def self.past
		where('timestamp < CURRENT_TIMESTAMP')
	end
	
	def current?
		self.timestamp > Time.zone.now
	end

	def past?
		self.timestamp < Time.zone.now
	end
	
end
