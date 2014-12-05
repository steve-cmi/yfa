class Event < ActiveRecord::Base

  has_many :event_dates, dependent: :delete_all, :order => '`event_dates`.`starts_at`'
  has_many :event_filters, dependent: :delete_all
  has_many :filters, through: :event_filters, uniq: true

  belongs_to :building

  attr_accessible :name, :minutes, :location, :featured, :building_id
  attr_accessible :description, :image, :sponsor_name, :sponsor_link

  has_attached_file :image,
    :styles => { :homepage => "125x125>", :grid => "125x125>", :popup => "220x220>" }
  
  validates_attachment_content_type :image,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.featured
    where(featured: true)
  end

  def self.current
    where(:id => EventDate.current.select(:event_id))
  end

  def self.archived
    where(:id => EventDate.archived.select(:event_id))
  end

  def self.by_date
    uniq.joins(:event_dates).order('`event_dates`.`starts_at` ASC')
  end

end
