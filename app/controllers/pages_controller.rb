class PagesController < ApplicationController
  def home
  end

  def about
  end
  
  def contact
  end
  
  def roadmap
  end
  
  def search
    @terms = params[:search].split.map{|s| s.strip}
    @users = User.scoped
    @events = Event.scoped
    @venues = Venue.scoped
    @terms.each do |term|
      @users = @users.search(term)
      @events = @events.search(term)
      @venues = @venues.search(term)
    end
    @events = @events.free if free?
    @events = @events.cheaper_than(params[:price_text]) if less?
    @events = @events.today if today?
    @events = @events.future if future?
    @events = @events.this_week if week?
    @events = @events.past if past?
    
    @users = [] unless users?
    @events = [] unless events?
    @venues = [] unless venues?    
  end
  
  helper_method :users?, :events?, :venues?, :free?, :less?, :any_price?,
    :future?, :today?, :week?, :past?
  private
    def users?
      params[:user]
    end
    def events?
      params[:event]
    end
    def venues?
      params[:venue]
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
    
    def future?
      params[:when] == 'future'
    end
    def today?
      params[:when] == 'today'
    end
    def week?
      params[:when] == 'week'
    end
    def past?
      params[:when] == 'past'
    end
end
