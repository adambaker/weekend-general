class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def sign_out
    @current_user = nil
    session[:user_id] = nil
  end
  
end
