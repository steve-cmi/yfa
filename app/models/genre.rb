class Genre < ActiveRecord::Base
  has_many :film_genres, dependent: :delete_all
  has_many :films, through: :film_genres

  acts_as_list

  validates :name, :presence => true
  validates :name, :uniqueness => true

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.by_position
    order(:position)
  end

end
