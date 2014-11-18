class ScreeningMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL
  
  def notify_oup_email(film, screening)
    @film = film
    @screening = screening
    mail(:to => ["steve.friedman@commonmediainc.com"], :subject => "[YFA Site] Screening Change for: " + film.title)
  end
end