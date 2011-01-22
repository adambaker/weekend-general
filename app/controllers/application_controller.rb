class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user, :current_theme, :can_alter?, :theme

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def sign_out
    @current_user = nil
    session[:user_id] = nil
  end
  
  def authenticate
    if current_user.nil?
      redirect_to '/auth/google'
    end
  end
  
  def current_theme(controller, message)
    theme[controller][message]
  end
  
  def can_alter?(object)
    object.created_by == current_user.id || current_user.rank > 1 
  end
  
  def theme
    if params[:theme]
      Themes::THEMES[params[:theme]]
    elsif current_user 
      Themes::THEMES[current_user.theme]
    else
      Themes::not_signed_in
    end
  end
end
