class Genre < ActiveRecord::Base
  acts_as_list

  has_many :films_genres, dependent: :destroy
  has_many :films, through: :genres

  attr_accessible :name

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.by_position
    order(:position)
  end

  attr_accessible :name
end
