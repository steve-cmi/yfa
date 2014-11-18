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
    uniq.joins(:event).where('`events`.`featured` IS TRUE')
  end

end
