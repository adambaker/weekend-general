class DevelopmentMailInterceptor
  
  def self.delivering_email(message)
    message.subject = "#{message.to} -- #{message.subject}"
    message.to = 'weekend.general@gmail.com'
  end
end
