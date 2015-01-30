class Filter < ActiveRecord::Base
  acts_as_list

  has_many :event_filters, dependent: :destroy
  has_many :events, through: :event_filters

  attr_accessible :name

  extend FriendlyId
  friendly_id :name, use: :slugged
  def should_generate_new_friendly_id?
    false
  end

  def self.by_position
    order(:position)
  end

  def undeletable?
    slug == 'screenings'
  end

  before_destroy :confirm_deletable
  def confirm_deletable
    return false if undeletable?
  end

end
