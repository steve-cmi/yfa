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
		:styles => { :homepage => "90x90>", :grid => "125x125>", :show => "360x>" }
	
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
	
	validates :title, :contact, :description, :start_date, :end_date, :presence => true
	validates :contact, :email_format => true

	extend FriendlyId
	friendly_id :title, use: :slugged

	delegate :directors, :actors, :writers, :cast, :crew, :to => :film_positions
	default_scope where(:approved => true)

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

	### S3 Attachments

	def s3_objects
		[] # Yale::s3_bucket.objects.with_prefix("films/#{id}/misc/") TODO : ITS SLOW!!
	end

	def s3_destroy(files)
		if files
			paths = files.collect {|file| "films/#{id}/misc/#{file}"}
	   	Yale::s3_bucket.objects.delete(paths)
  	end
	end

	def s3_create(data)
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

		return auditions if auditions.length <= 1

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

	after_update :check_to_notify_changes
	def check_to_notify_changes
		# NOTE: DOESN'T COVER NESTED ATTRIBUTES. Those are handled on the respective models
		if self.approved_changed? && self.approved
			# Send OUP a note about the new film. Maybe send the film a note too!
			FilmMailer.film_approved_email(self).deliver
		end
	end
	
end
