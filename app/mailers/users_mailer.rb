class UsersMailer < ActionMailer::Base
  default from: "weekend.general@gmail.com"
  helper :application
  
  def enlist(user)
    @user = user
    mail(to: @user.email, subject: 'New recruit orientation').deliver
  end
  
  def tracked_rsvp(tracker, target, event)
    @user = tracker
    @target = target
    @event = event
    
    mail(to: @user.email, subject: "#{target.name} has rsvp'd to an event.")
      .deliver
  end
  
  def self.notify_trackers(target, event, rsvp_kind)
    target.trackers.each do |tracker|
      if (rsvp_kind == 'host' && tracker.track_host) ||
         (rsvp_kind == 'attend' && tracker.track_attend) ||
         (rsvp_kind == 'maybe' && tracker.track_maybe)
        UsersMailer.tracked_rsvp(tracker, target, event)
      end
    end
  end
  
  def event_reminder(user)
    @user = user
    @events = []
    @events += user.attending.today.all if user.attend_reminder
    @events += user.maybes.today.all if user.maybe_reminder
    @events += user.hosting.today.all if user.host_reminder
    event_names = @events.map{|e| e.name}.join(', ')
    unless @events.empty?
      mail(to: "#{user.name} <#{user.email}>", 
        subject: "Weekend General reminder: #{event_names}").deliver
    end
  end
  
  def self.send_all_reminders
    User.all.each do |u|
      if u.attend_reminder || u.maybe_reminder || u.host_reminder
        UsersMailer.event_reminder(u)
      end
    end
  end
end
