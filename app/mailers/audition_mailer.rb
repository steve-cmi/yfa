class AuditionMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL

  def confirmation_email(audition)
    @audition = audition
    mail(:to => audition.email, :subject => "[YFA Site] Audition Confirmation: " + audition.film.title) unless audition.email.blank?
  end

end
