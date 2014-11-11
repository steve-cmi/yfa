class ShowtimeMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL
  
  def notify_oup_email(film, showtime)
    @film = film
    @showtime = showtime
    mail(:to => ["steve.friedman@commonmediainc.com"], :subject => "[YFA Site] Showtime Change for: " + film.title)
  end
end