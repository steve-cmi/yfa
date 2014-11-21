class Building < ActiveRecord::Base

  has_many :events
  has_many :screenings

  attr_accessible :code, :name, :address, :city_state, :zip

end
