class Film < ActiveRecord::Base

	has_many :showtimes, :dependent => :destroy, :order => "timestamp ASC"
	has_many :film_positions, :dependent => :delete_all, :include => :person
	has_many :permissions, :dependent => :delete_all
	has_many :auditions, :dependent => :destroy

	has_attached_file :poster, :styles => { :medium => "480x400>", :thumb => "150x150>" },				
				:storage => :s3,
     		:s3_credentials => "#{Rails.root}/config/aws.yml",
    		:path => "/films/:id/poster/:style/:filename"
	
	default_scope where(:approved => true)
	
	attr_accessible :category, :title, :tagline, :url_key, :contact, :description, :poster, :accent_color, :flickr_id
	attr_accessible :auditions_enabled, :aud_info, :start_date, :end_date
	attr_accessible :showtimes_attributes, :film_positions_attributes, :permissions_attributes
	attr_accessible :directors if Rails.env.development?
	accepts_nested_attributes_for :showtimes, :allow_destroy => true
	accepts_nested_attributes_for :film_positions, :allow_destroy => true
	accepts_nested_attributes_for :permissions, :allow_destroy => true
	
	# Ensure unique slug
	validates_format_of :url_key, :with => /\A[a-z0-9_]+\Z/i, :message => "The url key should contain only letters and numbers", :allow_blank => true
	validates_uniqueness_of :url_key, :allow_blank => true, :case_sensitive => false, :message => "Sorry, the desired url is already taken. Please try another!"

	validates :category, :title, :contact, :description, :start_date, :end_date, :presence => true
	validates :contact, :email_format => true
	validates_columns :category

	extend FriendlyId
	friendly_id :title, use: :slugged

	after_update :check_to_notify_changes

	delegate :directors, :actors, :writers, :cast, :crew, :to => :film_positions

	def director
		directors.first.person
	end

	scope :by_date, order(:start_date, :end_date)
	
	def self.films_in_range(range)
		Film.where(:id => Showtime.select(:film_id).where(:timestamp => range))
	end

	def poster_ratio
		return nil unless poster.exists?
		poster.width(:medium).to_f / poster.height(:medium).to_f
	end

	def has_opportunities?
		film_positions.cast.vacant.any?
	end
	
	def has_future_auditions?
	  auditions.where(["`timestamp` > ?", Time.now]).count > 0
	end
	
	# All films till the next Sunday
	def self.this_week
		range = (Time.now .. Time.now.sunday)
		range = (Time.now .. Time.now.next_week(:sunday)) if Time.now.sunday?
		
		self.films_in_range(range)
	end
	
	# All films which haven't yet closed
	def self.future
		self.joins(:showtimes).where(["showtimes.timestamp >= ?",Time.now]).order("showtimes.timestamp")
	end

	def has_opened?
		self.showtimes.sort_by{|st| st.timestamp}.first.timestamp.to_time >= Time.now
	end
	
	def has_closed?
		self.showtimes.sort_by{|st| st.timestamp}.last.timestamp.to_time < Time.now
	end
	
	# Get the OCI term of the film's first showtime, can help for categorizing
	def semester
		return nil unless self.showtimes.first
		opens = self.open_date
		if(opens.month < 7)
			opens.year.to_s + "01"
		else
			opens.year.to_s + "03"
		end
	end

	def open_date
		self.showtimes.first.timestamp
	end
	
	# Helper for figuring out if it's this academic semester.
	# @note Expects that films won't span semesters, only uses opening date
	def this_semester?
		opens = self.open_date
		today = Time.now
		
		# TODO: rewrite into a range so it's a bit cleaner
		if(opens.month > 7 && today.month > 7 && today.year == opens.year)
			true
		elsif(opens.month <= 7 && today.month <= 7 && today.year == opens.year)
			true
		else
			false
		end
	end
	
	# Helper for figuring out if the given film is running this week
	def this_week?
		range = (Time.now .. Time.now.sunday)
		range = (Time.now .. Time.now.next_week) if(Time.now.sunday?)
		self.showtimes.detect{ |st| range.cover? st.timestamp }
	end
	
	def self.films_in_term(oci_term)
		range = self.term_to_range(oci_term)
		self.films_in_range(range)
	end
	
	private

	def check_to_notify_changes
		# NOTE: DOESN'T COVER NESTED ATTRIBUTES. Those are handled on the respective models
		if self.approved_changed? && self.approved
			# Send OUP a note about the new film. Maybe send the film a note too!
			FilmMailer.film_approved_email(self).deliver
		end
	end
	
	# Helper function to convert a static oci_term into a rails date range for querying
	# @param oci_term [String] the oci_term to search for, i.e. 201201 = spring 2012, 201103 = fall 2011
	def self.term_to_range(oci_term)
		year = oci_term.slice(0,4).to_i
		if(oci_term.slice(4,2).to_i == 1)
			#spring
			range = (Time.new(year,1,1).. Time.new(year,7,1))
		else
			#fall
			range = (Time.new(year,7,1).. Time.new(year,12,31))
		end
		range
	end

	#### New code added by steve@commonmedia.com March 2013.

	public

	# Conditionally exclude or include certain event types.
	### TODO: DO films have categories?
	def self.in_category(category)
		where(:category => category)
	end

	def self.coming_soon
		in_category([:comedy, :dance, :theater])
	end

	def self.on_film_page
		in_category([:dance, :theater])
	end

	def self.on_people_page
		in_category([:dance, :theater])
	end

	# Find films by semester and academic year.
	def self.upcoming
		# not reusing self.future because joins break subqueries
		where(:id => Showtime.select(:film_id).upcoming)
	end

	def self.this_semester
		where(:id => Showtime.select(:film_id).this_semester)
	end

	def self.this_year
		where(:id => Showtime.select(:film_id).this_year)
	end

	####

end
