class Video < ActiveRecord::Base
  acts_as_list

  belongs_to :film

  def self.by_position
    order(:position)
  end

end
