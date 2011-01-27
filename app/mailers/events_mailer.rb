class EventsMailer < ActionMailer::Base
  default from: "weekend.general@gmail.com"
  layout 'users_mailer'
  helper 'application'
  
  def new_rsvp(user, rsvp_user, event, kind)
    @user = user
    @rsvp_user = rsvp_user
    @event = event
    @kind = kind
    unless user == rsvp_user
      mail(to: user.email, 
        subject: "#{rsvp_user.name} has rsvp'd to #{event.name}").deliver
    end
  end
end
