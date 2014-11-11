class Showtime < ActiveRecord::Base	
	belongs_to :show
	
	after_create :notify_oup
	after_update :notify_oup
	before_destroy :prevent_last_showtime_deletion
	
	def prevent_last_showtime_deletion
		return false if self.show && self.show.showtimes.count == 1
	end

	def self.future
		where(["showtimes.timestamp >= ?",Time.now])
	end
	
	# hack helper...don't use this, use application_helper instead
	def short_display_time
		self.timestamp.strftime("%b %d %-l:%M %p")
	end

	def notify_oup
		return unless self.timestamp_changed?
		@show = self.show rescue nil # will error if show can't be found, meaning not approved
		ShowtimeMailer.notify_oup_email(@show,self).deliver if @show && @show.approved		
	end
	
	#### New code added by steve@commonmedia.com March 2013.

	# Find showtimes by semester and academic year.
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
