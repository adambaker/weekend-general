class PagesController < ApplicationController
  before_filter :fetch_events, only: [:search]
  
  def home
    @rsvps = current_user.target_rsvps if current_user
    @new_events = Event.recently_added.limit(5)
    @updated_events = Event.recently_updated.limit(5)
  end

  def about
  end
  
  def contact
  end
  
  def roadmap
  end
  
  def search
    @terms = params[:search] ? params[:search].split.map{|s| s.strip} : []
    @users = User.scoped
    @venues = Venue.scoped
    @terms.each do |term|
      @users = @users.search(term) if users?
      @events = @events.search(term) if events?
      @venues = @venues.search(term) if venues?
    end
    
    @users = [] unless users?
    @events = [] unless events?
    @venues = [] unless venues?    
  end
  
  helper_method :users?, :events?, :venues?, :future?, :today?, :week?, :past?
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
    
    def future?
      params[:when] == 'future'
    end
    def today?
      params[:when] == 'today'
    end
    def week?
      params[:when] == 'week'
    end
    def month?
      false
    end
    def past?
      params[:when] == 'past'
    end
end
