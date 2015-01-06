class FilmMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL

  def need_approval_email(film)
    @film = film
    mail(:to => YFA_EMAIL, :subject => "[YFA Site] Approval Request: " + film.title)
  end

  def film_approved_email(film)
    @film = film
    mail(:to => [film.contact, YFA_EMAIL, YCA_EMAIL], :subject => "[YFA Site] New Film Approved: " + film.title)
  end

end
