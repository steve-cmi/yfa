class Film < ActiveRecord::Base

	has_many :film_positions, :dependent => :delete_all, :include => [:position, :person]
	has_one :film_director, :class_name => 'FilmPosition', :conditions => "position_id = #{Position.director_id}", :include => :person
	has_one :director, :source => :person, :through => :film_director
	
	has_many :screenings, :dependent => :delete_all, :include => :building
	has_many :permissions, :dependent => :delete_all
	has_many :auditions, :dependent => :delete_all, :order => :starts_at
  has_many :film_genres, dependent: :delete_all
  has_many :genres, through: :film_genres, uniq: true
  has_many :links, :as => :item, :dependent => :delete_all, :order => :position

	has_attached_file :poster,
		:styles => { :homepage => "90x90#", :grid => "125x125#", :show => "360x>" }
	
  validates_attachment_content_type :poster,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

	attr_accessible :title, :tagline, :slug, :contact, :description, :poster
	attr_accessible :auditions_enabled, :aud_info, :start_date, :end_date
	attr_accessible :directors if Rails.env.development?
	
	attr_accessible :film_positions_attributes, :film_genres_attributes
	attr_accessible :screenings_attributes, :permissions_attributes, :links_attributes
	accepts_nested_attributes_for :film_positions, :allow_destroy => true
	accepts_nested_attributes_for :film_genres, :allow_destroy => true
	accepts_nested_attributes_for :screenings, :allow_destroy => true
	accepts_nested_attributes_for :permissions, :allow_destroy => true
	accepts_nested_attributes_for :links, :allow_destroy => true
	
	validates :title, :contact, :start_date, :end_date, :presence => true
	validates :contact, :email_format => true

	extend FriendlyId
	friendly_id :title, use: :slugged

	delegate :directors, :actors, :writers, :cast, :crew, :to => :film_positions
	default_scope where(:approved => true)

	def self.future
		where('`films`.`end_date` >= ?', Date.today)
	end

	def self.archived
		where(:archive => true)
	end

	def self.pending
		unscoped.where(:approved => false)
	end
	
	def has_opportunities?
		film_positions.cast.vacant.any?
	end
	
	def has_future_auditions?
	  auditions.immediate_future.any?
	end

	def self.has_auditions
		where(:id => Audition.imminent.select(:film_id))
	end

	def self.by_title
		order(:title)
	end

	## Director assignment

	def director=(person)
		@director = person
	end

	after_save :save_director
	def save_director
		if @director
			if film_director
				success = film_director.update_attribute(:person_id, @director.id)
			else
				success = film_positions.create(:position_id => Position.director_id, :person_id => @director.id)
			end
			@director = nil if success
		end
	end

	validate :director_must_exist
	def director_must_exist
		unless director_exists?
			errors.add(:director, "must be selected")
		end
	end

	def director_exists?
		return true if @director
		return true if film_positions.find {|fp| fp.position_id == Position.director_id}
	end

	## Date functions

	def started?
		start_date >= Date.today
	end
	
	def ended?
		end_date < Date.today
	end
	
	def month
		start_date.month
	end

	def year
		start_date.year
	end

	def self.by_date
		order(:start_date, :end_date)
	end
	
	## Date range functions
	
	def self.in_range(range)
		where(:start_date => range)
	end

	def self.current
		where('end_date >= CURRENT_TIMESTAMP')
	end

	def self.past
		where('end_date < CURRENT_TIMESTAMP')
	end

	## WEEK

	def self.this_week
		in_range(Yale::this_week)
	end
	
	def this_week?
		Yale::this_week.include?(start_date)
	end

	## SEMESTER
	
	# automatically set semester_code from start_date
	before_save :set_semester_code
	def set_semester_code
		if start_date_changed?
			self.semester_code = Yale::semester_code_for(start_date)
		end
	end

	def update_semester_code
		set_semester_code
		save
	end

	def season_code
		semester_code[-2,2]
	end

	def spring?
		season_code == Yale::spring_code
	end

	def fall?
		season_code == Yale::fall_code
	end

	def this_year?
		start_date > Yale::year_start and start_date < Yale::year_end
	end

	def this_semester?
		semester_code == Yale::this_semester
	end
	
	def self.for_semester(semester_code)
		where(:semester_code => semester_code)
	end

	def self.before_semester(semester_code)
		where('semester_code < ?', semester_code)
	end

	def self.this_semester
		for_semester(Yale::this_semester)
	end

	def self.next_semester
		for_semester(Yale::next_semester)
	end

	def self.last_semesters
		before_semester(Yale::this_semester)
	end

	def self.recent
		for_semester([Yale::this_semester, Yale::last_semester])
	end

	def semester_label
		Yale::semester_label_for start_date
	end

	### S3 Attachments

	def s3_objects?
		s3_objects.any? if s3_objects
	end

	def s3_objects
		@s3_objects ||= Yale::s3_bucket.objects.with_prefix("films/#{id}/misc/") rescue nil
	end

	def s3_destroy(files)
		if files
	   	@s3_objects = nil
			paths = files.collect {|file| "films/#{id}/misc/#{file}"}
	   	Yale::s3_bucket.objects.delete(paths)
  	end
	end

	def s3_create(data)
   	@s3_objects = nil
	  orig_filename =  data.original_filename
	  filename = File.basename(orig_filename).gsub(/[^\w\.\-]/,'_')
	  ext = File.extname(filename).downcase
	  raise unless ['.jpg','.jpeg','.gif','.png','.doc','.docx','.xls','.xlsx','.pdf','.txt'].include?(ext)
	  Yale::s3_bucket.objects["films/#{id}/misc/#{filename}"]
	  	.write(:file => data.tempfile, :access => :public_read)
	end

	# TODO: before_destroy, delete all attachments?!

	### Audition groups

	def audition_groups
		@audition_groups ||= render_audition_groups
	end

	def render_audition_groups
		auditions = self.auditions.order(:starts_at).all

		return [] if auditions.length == 0
		return [auditions] if auditions.length == 1

		last_ts = auditions.first.starts_at
		expected_gap = auditions[1].starts_at - auditions[0].starts_at # Naive...might be improved somehow
		groups = []
		group = []

		# If the next audition is in the expected gap, then push it into this group
		auditions.each do |a|
			if a.starts_at - last_ts <= expected_gap * 3
				group << a
			else
				groups << group
				group = [a]
			end
			last_ts = a.starts_at
		end
		groups << group
		groups
	end

	private

	after_update :send_approval_email
	def send_approval_email
		if self.approved_changed? && self.approved
			FilmMailer.film_approved_email(self).deliver
		end
	end
	
end
