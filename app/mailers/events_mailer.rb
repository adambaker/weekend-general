class EventsMailer < ActionMailer::Base
  default from: "weekend.general@gmail.com"
  layout 'users_mailer'
  helper 'application'
  
  def new_event(user, event)
    @user = user
    @event = event
    unless user.id == event.created_by
      mail(to: user.email, subject: "New event #{event.name} added").deliver
    end
  end
  
  def self.all_new_event(event)
    User.find_all_by_new_event(true).each{|u| EventsMailer.new_event(u, event)}
  end
  
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
  
  def self.all_new_rsvp(user, event, kind)
    to_mail = []
    to_mail += event.hosts.find_all{|u| u.host_rsvp}
    to_mail += event.attendees.find_all{|u| u.attend_rsvp}
    to_mail += event.maybes.find_all{|u| u.maybe_rsvp}
    to_mail.each {|u| EventsMailer.new_rsvp(u, user, event, kind)}
  end
end
