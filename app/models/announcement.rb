class Announcement < ActiveRecord::Base

  validates :title, :body, :link_text, :link_url, :length => { :maximum => 255 }
  validates :title, :body, :presence => true

  def self.active
    where(:active => true)
  end

end
