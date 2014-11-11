class NewsletterMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL

  def newsletter_email(films, auditions, announcements, opportunities, request)
  	@films = films
  	@auditions = auditions
  	@announcements = announcements
  	@opportunities = opportunities
    @request = request

  	subject = if Time.now.sunday?
      time_next_week = Time.now + 7.days
			"YFA Newsletter - Week of " + Time.now.strftime("%B %e") + " - " + time_next_week.strftime("%B %e")
		else
			"YFA Newsletter - Week of " + Time.now.strftime("%B %e") + " - " + Time.now.sunday.strftime("%B %e")
		end
    mail(:to => ["steve.friedman@commonmediainc.com"], :subject => subject)
  end
end