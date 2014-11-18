class Filter < ActiveRecord::Base

  has_many :events_filters, dependent: :destroy
  has_many :events, through: :filters

  attr_accessible :name

  extend FriendlyId
  friendly_id :name, use: :slugged

end