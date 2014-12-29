class Event < ActiveRecord::Base

  has_many :event_dates, dependent: :delete_all, :order => '`event_dates`.`starts_at`'
  has_many :event_filters, dependent: :delete_all
  has_many :filters, through: :event_filters, uniq: true

  belongs_to :person
  belongs_to :building

  has_attached_file :image,
    :styles => { :homepage => "125x125>", :grid => "125x125>", :popup => "220x220>", :show => "360x>" }
  
  validates_attachment_content_type :image,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  attr_accessible :name, :minutes, :image, :description, :sponsor_name, :sponsor_link, :location, :building_id

  attr_accessible :event_dates_attributes, :event_filters_attributes
  accepts_nested_attributes_for :event_dates, :allow_destroy => true
  accepts_nested_attributes_for :event_filters, :allow_destroy => true

  extend FriendlyId
  friendly_id :name, use: :slugged

  default_scope where(:approved => true)

  def self.pending
    unscoped.where(:approved => false)
  end
  
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

  def featured_date
    event_dates.current.first || event_dates.archived.last
  end

  private

  after_update :send_approval_email
  def send_approval_email
    if self.approved_changed? && self.approved
      EventMailer.event_approved_email(self).deliver
    end
  end

end
