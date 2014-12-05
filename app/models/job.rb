class Job < ActiveRecord::Base

  validates :start_date, :end_date, :position, :title, :company, :description, :presence => true

  def self.by_date
    order(:start_date, :end_date)
  end

  def self.by_position
    order(:position)
  end

  def self.by_location
    order(:country, :state, :city)
  end

  def self.in_country(country)
    where(:country => country)
  end

  def self.in_state(state)
    where(:state => state)
  end

  def self.paid
    where('compensation IS NOT NULL')
  end

  def self.unpaid
    where('compensation IS NULL')
  end

  def self.alumni_affiliated
    where(:alumni_affiliation => true)
  end

  def self.not_alumni_affiliated
    where(:alumni_affiliation => false)
  end

  def self.current
    # TODO: confirm - start or end date?
    where('start_date > CURRENT_TIMESTAMP')
  end

  def full_address
    [street, suite, city_state_zip.join(', '), country].reject(&:blank?)
  end

  def city_state_zip
    [city, state, zip].reject(&:blank?)
  end

end
