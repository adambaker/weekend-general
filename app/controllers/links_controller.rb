class LinksController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_event
  
  def create
    link = @event.links.build params[:link]
    flash[:success] = "The link was added to the event." if link.save
    redirect_to edit_event_path @event
  end
  
  def update
    link = @event.links.find_by_id params[:id]
    if link.update_attributes(params[:link])
      flash[:success] = "The link has been updated." 
    end
    redirect_to edit_event_path @event
  end
  
  def destroy
    @event.links.find_by_id(params[:id]).destroy
    redirect_to edit_event_path @event
  end
  
  private
  
    def fetch_event
      @event = Event.find_by_id params[:event_id]
    end
end
