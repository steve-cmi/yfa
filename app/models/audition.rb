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

	def self.group_into_blocks(auditions)
		return [] if auditions.length == 0
		return [auditions] if auditions.length == 1
		auditions.sort_by!(&:starts_at)
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
		
	after_update :audition_confirmation
	def audition_confirmation
		return unless self.person_id_changed? && self.person_id
		AuditionMailer.confirmation_email(self).deliver
	end
	
end