class EventsFilter < ActiveRecord::Base

  belongs_to :event
  belongs_to :filter

end