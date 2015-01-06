class Building < ActiveRecord::Base

  has_many :events
  has_many :screenings

  attr_accessible :code, :name, :address, :city_state, :zip

  validates :code, :name, :presence => true

  def self.by_name
    order(:name)
  end

end
