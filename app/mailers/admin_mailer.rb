class AdminMailer < ActionMailer::Base
	default :from => YFA_EMAIL
	def staff_email(recipients, subject, message)
		mail(:to => recipients, :subject => subject, :body => message) unless recipients.blank?
	end
end