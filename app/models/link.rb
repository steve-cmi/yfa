class Link < ActiveRecord::Base
  acts_as_list :scope => :item

  belongs_to :item, :polymorphic => true

  def self.by_position
    order(:position)
  end
end
