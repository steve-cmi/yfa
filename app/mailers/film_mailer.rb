class FilmMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL

  def need_approval_email(film)
    @film = film
    mail(:to => YFA_EMAIL, :subject => "[YFA Site] Approval Request: " + film.title)
  end

  def film_approved_email(film)
    @film = film
    mail(:to => [film.contact,"steve.friedman@commonmediainc.com"], :subject => "[YFA Site] New Film Approved: " + film.title)
  end

  def film_changed_email(film, changes)
  	@film = film
  	@changes = changes
    mail(:to => ["steve.friedman@commonmediainc.com"], :subject => "[YFA Site] Film Changed: " + film.title)
  end

end