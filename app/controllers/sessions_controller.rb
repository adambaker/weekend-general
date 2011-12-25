class SessionsController < ApplicationController  
  before_filter :check_discharge, only: [:create]

  def create
    user = User.find_by_provider_and_uid(@auth["provider"], @auth["uid"]) 
    if current_user
      flash[:notice] = current_theme 'sessions', 'already_signed_in'
      redirect_to current_user
    elsif user.nil?
      redirect_to controller: :users, action: :new, user: { 
          provider: @auth['provider'],
          name:     @auth['info']['name'], 
          uid:      @auth['uid'], 
          email:    @auth['info']['email'],
      }                
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

  def check_discharge
    @auth = request.env["omniauth.auth"]
    discharge = 
      DishonorableDischarge.find_by_email(@auth['info']['email']) ||
      DishonorableDischarge.find_by_provider_and_uid(@auth['provider'], @auth['uid'])
    if discharge
      flash[:notice] = "You've been dishonorably discharged. 
        You may appeal to an officer be reinstated.\n
        Reason for this discharge:\n#{discharge.reason}"
      redirect_to '/users/officers'
    end
  end
end
