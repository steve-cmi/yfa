class Job < ActiveRecord::Base

  validates :start_date, :end_date, :position, :title, :company, :description, :presence => true

  def self.by_start_date
    order(:start_date, :end_date)
  end

  def self.by_post_date
    order(:created_at).reverse_order
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
    where('end_date > CURRENT_TIMESTAMP')
  end

  def full_address
    [street, suite, city_state_zip.join(', '), country].reject(&:blank?)
  end

  def city_state_zip
    [city, state, zip].reject(&:blank?)
  end

  def united_states?
    country == 'US' or country.blank?
  end

  def us_state
    state if united_states?
  end

  def province
    state unless united_states?
  end

  def us_state=(state)
    self.state = state
  end
  alias_method :province=, :us_state=

end
