class Activity < ActiveRecord::Base
  has_many :experiences, :dependent => :destroy
  has_many :interests, :dependent => :destroy

  acts_as_list

  def self.by_position
    order(:position)
  end

  def self.by_name
    order(:name)
  end
end
