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
  
end
