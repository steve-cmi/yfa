class Building < ActiveRecord::Base

  has_many :events

  attr_accessible :code, :name, :address, :city_state, :zip

end
