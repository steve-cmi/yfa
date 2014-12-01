class Page < ActiveRecord::Base
  acts_as_list :scope => 'menu = \'#{menu}\''

  extend FriendlyId
  friendly_id :title, use: :slugged

  # The page author should set the slug.
  def should_generate_new_friendly_id?
    false
  end

  has_attached_file :image,
    :styles => { :show => "360x>" }
  
  validates_attachment_content_type :image,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  def self.by_position
    order(:position)
  end

  def self.main
    where(:menu => 'main')
  end

  def self.resources
    where(:menu => 'resources')
  end

  def self.howtos
    where(:menu => 'howtos')
  end

  def main?
    menu == 'main'
  end

  def resource?
    menu == 'resources'
  end

  def howto?
    menu == 'howtos'
  end

end
