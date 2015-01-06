class EventMailer < ActionMailer::Base
	add_template_helper(ApplicationHelper)

  default :from => YFA_EMAIL

  def need_approval_email(event)
    @event = event
    mail(:to => YFA_EMAIL, :subject => "[YFA Site] Approval Request: " + event.name)
  end

  def event_approved_email(event)
    @event = event
    mail(:to => [event.person.email, YFA_EMAIL, YCA_EMAIL], :subject => "[YFA Site] New Event Approved: " + event.name)
  end

end
