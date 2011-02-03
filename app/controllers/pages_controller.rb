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
  end
end
