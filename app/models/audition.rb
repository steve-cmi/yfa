class Audition < ActiveRecord::Base	

	belongs_to :film
	belongs_to :person
	
	validates :location, :presence => true
	
	default_scope :order => 'starts_at ASC'

	def self.imminent
		where(["starts_at > ?", 10.minutes.from_now])
	end

	def self.current
		where(['starts_at > ?', Time.now])
	end

	def self.recent
		where(['starts_at BETWEEN ? and ?', 5.days.ago, Time.now])
	end

	def filled?
		person_id?
	end

	def vacant?
		!filled?
	end

	def date
		starts_at.to_date
	end

	def past?
		starts_at <= Time.zone.now
	end

	def future?
		starts_at > Time.zone.now
	end

	def signup!(person, params)
		self.person = person
		self.name = person.name
		self.phone = params[:phone]
		self.email = params[:email]
		self.save!
	end

	def cancel!
		self.person = self.name = self.phone = self.email = nil
		self.save!
	end

	def self.to_csv
    require 'csv'
		CSV.generate do |csv| 
	    order(&:starts_at).includes(:person).all.each do |audition|
	    	data = [audition.starts_at.to_s, audition.location]
	    	data += [audition.person.display_name, audition.email, audition.phone] if audition.person
	      csv << data
	    end
	  end
	end

	private
		
	after_update :audition_confirmation
	def audition_confirmation
		return unless self.person_id_changed? && self.person_id
		AuditionMailer.confirmation_email(self).deliver
	end
	
end