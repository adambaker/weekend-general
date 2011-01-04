class SessionsController < ApplicationController  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) 
    if current_user
      flash[:notice] = Themes::current_theme['sessions']['already_signed_in']
      redirect_to current_user
    elsif user.nil?
      redirect_to controller: :users, action: :new,  
        user: { provider: auth['provider'], name: auth['user_info']['name'], 
          uid: auth['uid'], email: auth['user_info']['email']}                
    else
      session[:user_id] = user.id
      flash[:notice] = Themes::current_theme['sessions']['sign_in']
      redirect_to root_url
    end
  end
  
  def destroy
    if current_user
      session[:user_id] = nil
      flash[:notice] = Themes::current_theme['sessions']['sign_out']
      redirect_to root_url
    else
      session[:user_id] = nil
      flash[:error] = Themes::current_theme['sessions']['already_signed_out']
      redirect_to root_url
    end
  end

end
