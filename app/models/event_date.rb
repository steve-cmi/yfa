class EventDate < ActiveRecord::Base

  belongs_to :event
  belongs_to :building

  def date
    starts_at.to_date
  end

  def ends_at
    starts_at + seconds
  end

  def seconds
    event_minutes * 60 if event_minutes
  end

  def event_minutes
    minutes || event.minutes
  end

  def event_location
    location || event.location
  end

  def event_building
    building || event.building
  end

  def event_image
    event.image
  end

  def self.by_date
    order(:starts_at)
  end

  def self.current
    where('`event_dates`.`starts_at` >= CURRENT_TIMESTAMP')
  end

  def self.archived
    where('`event_dates`.`starts_at` < CURRENT_TIMESTAMP')
  end

  def self.featured
    uniq.joins(:event).where(events: {featured: true})
  end

  def self.approved
    uniq.joins(:event).where(events: {approved: true})
  end

  def self.filtered_by(filter)
    uniq.joins(:event => :event_filters).where(event_filters: {filter_id: filter.id})
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
