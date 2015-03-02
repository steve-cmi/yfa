class Person < ActiveRecord::Base	
	require 'net/ldap'

  has_many :film_positions, :dependent => :delete_all
  has_many :permissions, :dependent => :delete_all
  has_many :films, :through => :permissions, :uniq => true
  has_many :events
  has_many :auditions, :dependent => :nullify
  has_many :takeover_requests, :dependent => :delete_all
  has_many :links, :as => :item, :dependent => :delete_all, :order => :position
  has_many :experiences, :dependent => :delete_all, :include => :activity
  has_many :experienced_activities, :source => :activity, :through => :experiences, :uniq => true
  has_many :interests, :dependent => :delete_all, :include => :activity
  has_many :interested_activities, :source => :activity, :through => :interests, :uniq => true

  has_attached_file :picture,
    :styles => { :show => "360x>" }
  
  validates_attachment_content_type :picture,
    content_type: /\Aimage\/(jpeg|gif|png)\Z/,
    message: 'file type is not allowed (only jpeg/png/gif images)'

  attr_accessible :fname, :lname, :email, :year, :college, :bio, :email_allow, :picture
  attr_accessible :active, :site_admin, :admin_admin, :netid

  attr_accessible :experiences_attributes, :interests_attributes, :links_attributes
  accepts_nested_attributes_for :experiences, :allow_destroy => true
  accepts_nested_attributes_for :interests, :allow_destroy => true
  accepts_nested_attributes_for :links, :allow_destroy => true
  
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

  def self.admins
    where(:site_admin => true)
  end

  def self.users
    where(:site_admin => [false, nil])
  end

  # Check if the user has permission for the given film
  def has_permission?(film)
    return true if site_admin?
    film_id = film.instance_of?(Film) ? film.id : film.to_i
    permissions.where(:film_id => film_id).any?
  end
  
  def similar_users
    @similar_users ||= find_similar_users
  end

  def find_similar_users
    people = []
    people += Person.find_all_by_fname_and_lname(self.fname, self.lname) if self.fname? and self.lname?
    people += Person.find_all_by_email(self.email) if self.email?
    people += Person.where(["fname LIKE ? AND lname = ?",self.fname.first(1) + "%", self.lname]) if self.fname? and self.lname?
    people.reject!(&:netid?)
    people.uniq - [self] - self.takeover_requests.collect(&:requested_person)
  end

  def self.autocomplete(query)
    where("`fname` LIKE ? OR `lname` LIKE ? OR CONCAT_WS(' ', `fname`, `lname`) LIKE ?", "#{query}%", "#{query}%", "#{query}%")
  end
  
  # Accessors 
  def name
    [fname, lname].reject(&:blank?).join(' ')
  end
  
	def display_name
    name
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
    
    # Don't save the model, because they are going to be shown a form to edit info
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
  
end