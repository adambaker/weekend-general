class ApplicationController < ActionController::Base
  protect_from_forgery
  
  helper_method :current_user, :current_theme, :can_alter?, :theme, :officer?,
    :free?, :less?, :any_price?, :date?, :price?, :created?, :updated?

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
  
  def officer?
    current_user && current_user.rank > 2
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
  
  def free?
    params[:price] == 'free'
  end
  def less?
    params[:price] == 'less'
  end
  def any_price?
    params[:price] == 'any'
  end
  
  def date?
    params[:order] == 'date'
  end
  def price?
    params[:order] == 'price'
  end
  def created?
    params[:order] == 'created'
  end
  def updated?
    params[:order] == 'updated'
  end
  
  def fetch_events
    if price?
      @events = Event.where('price IS NOT NULL').order(:price)
    elsif created?
      @events = Event.order('created_at DESC')
    elsif updated?
      @events = Event.order('updated_at DESC')
    else #date ordering by default
      if past?
        @events = Event.order('date DESC')
      else
        @events = Event.order('date')
      end
    end
    
    if free?
      @events = @events.free
    elsif less?
      @events = @events.cheaper_than(params[:price_text])
    end #default to any, no filtering required
    
    if today?
      @events = @events.today
    elsif week? 
      @events = @events.this_week
    elsif month?
      @events = @events.this_month 
    elsif past?
      @events = @events.past
    else
      @events = @events.future  #default to future
    end
  end
end
