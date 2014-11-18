class Filter < ActiveRecord::Base
  acts_as_list

  has_many :events_filters, dependent: :destroy
  has_many :events, through: :filters

  attr_accessible :name

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.by_position
    order(:position)
  end

end