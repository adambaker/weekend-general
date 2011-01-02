class SessionsController < ApplicationController  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) 
    if current_user
      flash[:notice] = "I already know you're here, warrior. Now get to work!"
      redirect_to current_user
    elsif user.nil?
      redirect_to controller: :users, action: :new,  
                  user: { provider: auth['provider'],
                          uid: auth['uid'],
                          name: auth['user_info']['name'],
                          email: auth['user_info']['email']
                  }
                        
    else
      session[:user_id] = user.id
      redirect_to root_url, :notice => "There you are. Now fall in."
    end
  end
  
  def destroy
    if current_user
      session[:user_id] = nil
      redirect_to root_url, :notice => "Dismissed!"
    else
      session[:user_id] = nil
      flash[:error] = 'You need to sound off before you can be dismissed!'
      redirect_to root_url
    end
  end

end
