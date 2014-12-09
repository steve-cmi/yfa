class EventDate < ActiveRecord::Base

  belongs_to :event

  def date
    starts_at.to_date
  end

  def ends_at
    starts_at + seconds
  end

  def seconds
    minutes = self.minutes
    minutes ||= event.minutes if event
    minutes * 60 if minutes
  end

  def self.by_date
    order('`event_dates`.`starts_at` ASC')
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

  def self.this_week
    start_time = Date.today.beginning_of_week
    end_time = start_time.next_week
    where(:starts_at => start_time..end_time)
  end

  def self.this_month
    start_time = Date.today.beginning_of_month
    end_time = start_time.next_month
    where(:starts_at => start_time..end_time)
  end

  def self.this_day
    start_time = Date.today
    end_time = Date.tomorrow
    where(:starts_at => start_time..end_time)
  end

end
