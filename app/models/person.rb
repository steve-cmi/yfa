class Person < ActiveRecord::Base	
	require 'net/ldap'

  has_many :film_positions, :dependent => :destroy
  has_many :permissions, :dependent => :delete_all
  has_many :auditions, :dependent => :nullify
  has_many :takeover_requests, :dependent => :destroy #Outgoing requests, incoming are invisible

  has_attached_file :picture,
    :styles => { }
  
  validates_attachment_content_type :picture,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  # TODO: Write a custom typo/distance algo and something else for nicknames
  # TODO: maybe allow a password for when they are gone? But we always have CAS right?
  
  attr_accessible :fname, :lname, :email, :year, :college, :bio, :email_allow, :picture
  attr_accessible :active, :site_admin, :netid if Rails.env.development?
  
  validates :fname, :lname, :presence => true
  validates :year, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1970, :less_than_or_equal_to => Time.now.year + 8 }, :allow_nil => true
  validates :college, :inclusion => { :in => Yale::colleges.flatten }, :allow_nil => true
  validates_format_of :email, :with => /^$|\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                              :message => "Must enter a valid email address."

  extend FriendlyId
  friendly_id :name, use: :slugged

	def display_name
		self.fname + " " + self.lname
	end
	
	# Check if the user has permission to admin the given film
	# @param film [Integer] the film id to check (can also be a film object)
	# @param type [Symbol] One of :full, or a different type which is also in the DB
	# @returns Boolean true if current user has permission
	def has_permission?(film, type, any = false)
		return true if self.site_admin?
		film_id = film.instance_of?(Film) ? film.id : film.to_i
		if(self.permissions.detect{|perm| perm.film_id == film_id && (any || perm.level == :full || perm.level == type)})
			true
		else
			false
		end
	end
	
	def similar_to_me
		people = []
		people.concat Person.find_all_by_fname_and_lname(self.fname, self.lname) unless self.fname.blank? || self.lname.blank?
		people.concat Person.find_all_by_email(self.email) unless self.email.blank?
		people.concat Person.where(["fname LIKE ? AND lname = ?",self.fname.first(1) + "%", self.lname]) unless self.fname.blank? || self.lname.blank?
		people.select! {|person| person.netid == nil }
		people.uniq - [self] - self.takeover_requests.map{|tor| tor.requested_person}
	end
    
  # Accessors 
  def name
    self.fname.capitalize + " " + self.lname.capitalize
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