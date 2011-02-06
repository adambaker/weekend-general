class PagesController < ApplicationController
  before_filter :fetch_events, only: [:search]
  def home
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
      @users = @users.search(term)
      @events = @events.search(term)
      @venues = @venues.search(term)
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
