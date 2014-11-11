class Audition < ActiveRecord::Base	
	belongs_to :film
	belongs_to :person
	
	after_update :audition_confirmation
	after_update :update_film
	after_destroy :update_auditioner # They can't destroy it, so film did
	
	validates :location, :presence => true
	
	default_scope :order => "timestamp ASC"
	scope :future, where(["timestamp > ?", Time.now + 10.minutes])
	
	def is_taken?
		!self.person_id.blank?
	end

	def self.group_into_blocks(auditions)
		return [] if auditions.length == 0
		return [auditions] if auditions.length == 1
		auditions.sort_by!(&:timestamp)
		last_ts = auditions.first.timestamp
		expected_gap = auditions[1].timestamp - auditions[0].timestamp # Naive...might be improved somehow
		groups = []
		group = []

		# If the next audition is in the expected gap, then push it into this group
		auditions.each do |a|
			if a.timestamp - last_ts <= expected_gap * 3
				group << a
			else
				groups << group
				group = [a]
			end
			last_ts = a.timestamp
		end
		groups << group
		groups
	end

	#### New code added by steve@commonmedia.com March 2013.

	def self.immediate_future
		# self.future is now plus 10 minutes
		where(['timestamp > ?', Time.now])
	end

	RECENT_PAST_DAYS = 5
	def self.recent_past
		where(['timestamp BETWEEN ? and ?', Time.now - RECENT_PAST_DAYS.days, Time.now])
	end

	####
	
	private
		
	def audition_confirmation
		return unless self.person_id_changed? && self.person_id
		AuditionMailer.confirmation_email(self).deliver
	end

	#TODO: check both of these against the *OLD* audition timestamp
	# Notify the auditioner of a change
	def update_auditioner
	end
	
	# Notify the film of a signup or whatever
	def update_film
	end
	
end