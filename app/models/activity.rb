class Activity < ActiveRecord::Base
  has_many :experiences, :dependent => :delete_all
  has_many :interests, :dependent => :delete_all

  acts_as_list

  validates :name, :presence => true
  validates :name, :uniqueness => true

  def self.by_position
    order(:position)
  end

  def self.by_name
    order(:name)
  end
end
