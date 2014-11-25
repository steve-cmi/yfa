class Page < ActiveRecord::Base
  acts_as_list :scope => 'menu = \'#{menu}\''

  has_attached_file :image,
    :styles => { :show => "360x>" }
  
  validates_attachment_content_type :image,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  def self.main
    where(:menu => 'main')
  end

  def self.by_position
    order(:position)
  end

end
