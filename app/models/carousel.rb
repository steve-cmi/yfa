class Carousel < ActiveRecord::Base
  
  attr_accessible :title, :body, :link, :active, :image

  acts_as_list

  has_attached_file :image,
    :styles => { :admin => "75x>", :homepage => "750x>" }

  validates_attachment_content_type :image,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  validates :title, :image, :presence => true

  def self.active
    where(active: true)
  end

  def self.order_by(site)
    order =
      if site.nil? || site.carousel_order.blank?
        :position
      else
        site.carousel_order
      end
    send "by_#{order}"
  end

  def self.by_position
    order(:position)
  end

  def self.by_random
    order('RAND()')
  end

end
