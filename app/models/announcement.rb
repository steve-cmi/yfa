class Announcement < ActiveRecord::Base

  validates :title, :body, :link_text, :link_url, :length => { :maximum => 255 }

  def self.active
    where(:active => true)
  end

end
