class Screening < ActiveRecord::Base	
	belongs_to :film
	
	after_create :notify_oup
	after_update :notify_oup
	before_destroy :prevent_last_screening_deletion
	
	def prevent_last_screening_deletion
		return false if self.film && self.film.screenings.count == 1
	end

	def self.future
		where(["screenings.timestamp >= ?",Time.now])
	end
	
	# hack helper...don't use this, use application_helper instead
	def short_display_time
		self.timestamp.strftime("%b %d %-l:%M %p")
	end

	def notify_oup
		return unless self.timestamp_changed?
		@film = self.film rescue nil # will error if film can't be found, meaning not approved
		ScreeningMailer.notify_oup_email(@film,self).deliver if @film && @film.approved		
	end
	
	#### New code added by steve@commonmedia.com March 2013.

	# Find screenings by semester and academic year.
	YEAR_START_MONTH = 8 # August is in the second semester, July is in the first

	def self.semester_start
		today = Date.today
		if today.month >= YEAR_START_MONTH
			Date.new today.year, YEAR_START_MONTH, 1
		else
			Date.new today.year, 1, 1
		end
	end

	def self.semester_end
		today = Date.today
		if today.month >= YEAR_START_MONTH
			Date.new today.year + 1, 1, 1
		else
			Date.new today.year, YEAR_START_MONTH, 1
		end
	end

	def self.year_start
		today = Date.today
		if today.month >= YEAR_START_MONTH
			Date.new today.year, YEAR_START_MONTH, 1
		else
			Date.new today.year - 1, YEAR_START_MONTH, 1
		end
	end

	def self.year_end
		today = Date.today
		if today.month >= YEAR_START_MONTH
			Date.new today.year + 1, YEAR_START_MONTH, 1
		else
			Date.new today.year, YEAR_START_MONTH, 1
		end
	end

	def self.this_semester
		where('timestamp BETWEEN ? AND ?', self.semester_start, self.semester_end)
	end

	def self.this_year
		where('timestamp BETWEEN ? AND ?', self.year_start, self.year_end)
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
	
	####
	
end
