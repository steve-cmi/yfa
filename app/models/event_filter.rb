class EventFilter < ActiveRecord::Base

  belongs_to :event
  belongs_to :filter

  validates :filter_id, :uniqueness => {:scope => :event_id, :message => "has already been assigned to this event"}

end