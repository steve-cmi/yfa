class Screening < ActiveRecord::Base	
	belongs_to :film
  belongs_to :building

  def date
    starts_at.to_date
  end

  def ends_at
    starts_at + seconds
  end

  def seconds
    minutes * 60 if minutes
  end

	def event_location
		location
	end

	def event_building
		building
	end

	def event_image
		film.poster
	end
	
  def self.approved
    uniq.joins(:film).where(films: {approved: true})
  end

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

  def self.week_of(date)
    start_time = date.beginning_of_week
    end_time = start_time.next_week
    where(:starts_at => start_time..end_time)
  end

  def self.month_of(date)
    start_time = date.beginning_of_month
    end_time = start_time.next_month
    where(:starts_at => start_time..end_time)
  end

  def self.day_of(date)
    start_time = date
    end_time = date + 1
    where(:starts_at => start_time..end_time)
  end
	
end
