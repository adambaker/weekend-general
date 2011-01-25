class UsersMailer < ActionMailer::Base
  default from: "weekend.general@gmail.com"
  
  def event_reminder(user)
    @user = user
    @events = []
    @events += user.attending.today.all if user.attend_reminder
    @events += user.maybes.today.all if user.maybe_reminder
    @events += user.hosting.today.all if user.host_reminder
    unless @events.empty?
      mail(to: "#{user.name} <#{user.email}>", 
        subject: "Weekend General reminder: #{@events[0].name}").deliver
    end
  end
end
