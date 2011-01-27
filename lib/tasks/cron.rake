
desc "This taks is called by the Heroku cron add-on"
task :cron => [:environment, :rsvp_reminder]

desc "Sends reminder emails to users who have RSVP'd to an event today."
task :rsvp_reminder do
  UsersMailer.send_all_reminders
  puts 'sent all reminders'
end
