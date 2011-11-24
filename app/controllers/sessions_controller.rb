class SessionsController < ApplicationController  
  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) 
    if current_user
      flash[:notice] = current_theme 'sessions', 'already_signed_in'
      redirect_to current_user
    elsif user.nil?
      redirect_to controller: :users, action: :new,  
        user: { provider: auth['provider'], name: auth['info']['name'], 
          uid: auth['uid'], email: auth['info']['email']}                
    else
      session[:user_id] = user.id
      flash[:notice] = current_theme 'sessions', 'sign_in'
      redirect_to session[:signin_back] || root_url
    end
  end
  
  def destroy
    if current_user
      flash[:notice] = current_theme 'sessions', 'sign_out'
      redirect_to controller: :pages, action: :home, theme: theme['name']
    else
      flash[:error] = current_theme 'sessions', 'already_signed_out'
      redirect_to root_url
    end
    session[:user_id] = nil
  end

end
