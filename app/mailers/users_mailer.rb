class UsersMailer < ActionMailer::Base
  default from: "weekend.general@gmail.com"
  helper :application
  
  def tracked_rsvp(tracker, target, event)
    @user = tracker
    @target = target
    @event = event
    
    mail(to: @user.email, subject: "#{target.name} has rsvp'd to an event.")
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
