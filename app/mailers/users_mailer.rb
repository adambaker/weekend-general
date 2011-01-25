class UsersMailer < ActionMailer::Base
  default from: "weekend.general@gmail.com"
  
  def event_reminder(user)
    @user = user
    @events = user.attending.today
    mail(to: "#{user.name} <#{user.email}>", 
      subject: "Weekend General reminder: #{@events[0].name}")
  end
end
