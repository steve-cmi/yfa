class Person < ActiveRecord::Base	
	require 'net/ldap'

  has_many :film_positions, :dependent => :destroy
  has_many :permissions, :dependent => :delete_all
  has_many :auditions, :dependent => :nullify
  has_many :takeover_requests, :dependent => :destroy

  has_many :links, :as => :item, :dependent => :destroy

  has_many :experiences, :dependent => :destroy
  has_many :interests, :dependent => :destroy

  has_attached_file :picture,
    :styles => { :show => "360x>" }
  
  validates_attachment_content_type :picture,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  attr_accessible :fname, :lname, :email, :year, :college, :bio, :email_allow, :picture
  attr_accessible :active, :site_admin, :netid if Rails.env.development?
  
  validates :fname, :lname, :presence => true
  validates :year, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1970, :less_than_or_equal_to => Time.now.year + 8 }, :allow_nil => true
  validates :college, :inclusion => { :in => Yale::colleges.flatten }, :allow_nil => true
  validates_format_of :email, :with => /^$|\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                              :message => 'must be a valid email address'

  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.by_first_last
    order(:fname, :lname)
  end

  def self.current
    where('year >= ?', Date.today.year)
  end

  def self.with_position(position_id)
    where(:id => FilmPosition.uniq.where(:position_id => position_id).select(:person_id))
  end

  # Check if the user has permission to admin the given film
  # @param film [Integer, Film] the film id or object to check
  # @param type [Symbol] One of :full, :any, or a type defined by the database
  # @returns Boolean true if current user has permission
  def has_permission?(film, type)
    return true if site_admin?
    film_id = film.instance_of?(Film) ? film.id : film.to_i
    permissions = self.permissions.where(:film_id => film_id)
    permissions = permissions.where(:level => [:full, type].uniq) unless type == :any
    permissions.any?
  end
  
  def similar_to_me
    people = []
    people += Person.find_all_by_fname_and_lname(self.fname, self.lname) if self.fname? and self.lname?
    people += Person.find_all_by_email(self.email) if self.email?
    people += Person.where(["fname LIKE ? AND lname = ?",self.fname.first(1) + "%", self.lname]) if self.fname? and self.lname?
    people.reject!(&:netid?)
    people.uniq - [self] - self.takeover_requests.collect(&:requested_person)
  end
  
  # Accessors 
  def name
    self.fname.capitalize + " " + self.lname.capitalize
  end
  
	def display_name
    name
	end
	
  def site_admin?
    # netIDs of current site admins
    ["cmi1"].include? self.netid
  end
  
  def needs_registration?
  	self.fname.blank?
  end

  #populate contact fields from LDAP
  def populateLDAP
    return unless Rails.env.production?
    #quit if no email or netid to work with
    self.email ||= ''
    return if !self.email.include?('@yale.edu') && !self.netid

    begin
      ldap = Net::LDAP.new( :host =>"directory.yale.edu" , :port =>"389" )

      #set e filter, use netid, then email
      if !self.netid.blank? #netid
        f = Net::LDAP::Filter.eq('uid', self.netid)
      else
        f = Net::LDAP::Filter.eq('mail', self.email)
      end

      b = 'ou=People,o=yale.edu'
      p = ldap.search(:base => b, :filter => f, :return_result => true).first
    
    rescue Exception => e
          guessFromEmail
    end

    return unless p
  
    self.netid = ( p['uid'] ? p['uid'][0] : '' )
    self.fname = ( p['knownAs'] ? p['knownAs'][0] : '' )
    self.fname ||= ( p['givenname'] ? p['givenname'][0] : '' )
    self.lname = ( p['sn'] ? p['sn'][0] : '' )
    self.email = ( p['mail'] ? p['mail'][0] : '' )
    self.year = ( p['class'] ? p['class'][0].to_i : 0 )
    self.college = ( p['college'] ? p['college'][0] : '' )
    
    # Don't save the model, because they are going to be filmn a form to edit info
    # self.save!
  end

  # not a yale email, just make best guess at it 
  def guessFromEmail
    name = self.email[ /[^@]+/ ]
    return false if !name
    name = name.split( "." )

    self.fname = name[0].downcase
    self.lname = name[1].downcase || ''
    self.save
  end

  #### New code added by steve@commonmedia.com March 2013.

  # Generate a list of people for the admin email_all form.
  def self.staff_for(film_option, position_option)

    # select films
    case film_option.to_sym
    when :upcoming
      films = Film.upcoming
    when :semester
      films = Film.this_semester
    when :year
      films = Film.this_year
    end

    # select positions
    case position_option.to_sym
    when :producers
      positions = FilmPosition.primary.producers
    when :contacts
      positions = FilmPosition.primary.contacts
    end

    # merge films and positions
    film_positions = positions.where(:film_id => films.select(:id))

    # select people
    Person.where(:id => film_positions.select(:person_id))

  end

  ####
  
end