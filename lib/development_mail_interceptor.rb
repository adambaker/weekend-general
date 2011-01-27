class DevelopmentMailInterceptor
  
  def self.delivering_email(message)
    message.subject = "#{message.to}; cc:#{message.cc}; bcc: #{message.bcc}" +
      " -- #{message.subject}"
    message.to = 'weekend.general@gmail.com'
    message.cc = nil
    message.bcc = nil
  end
end
