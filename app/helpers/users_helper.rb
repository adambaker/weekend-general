module UsersHelper
  def project_contributers
    ['adam.durandal@gmail.com']
  end

  def rank_title(user)
    return 'colonel' if project_contributers.include? user.email
    
    case user.rank
    when 1
      'private'
    when 2
      'sergeant'
    when 3
      'lieutenant'
    when 4
      'major'
    end
  end
  
  def event_date(event)
    date_format = '%a, %b %d'
    date_format += ' %Y' unless event.date.year == Time.zone.now.year
    event.date.strftime(date_format)
  end
end
