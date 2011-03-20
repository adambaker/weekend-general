class RsvpsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_rsvp_data

  def create
    @kind = params['kind']
    current_user.send @kind, @event
    @id = @event.rsvps.find_by_user_id(current_user.id)
    UsersMailer.notify_trackers(current_user, @event, @kind)
    EventsMailer.all_new_rsvp(current_user, @event, @kind)
    
    respond_to do |format|
      format.html { redirect_to @event }
      format.json {}
    end
  end
  
  def destroy
    current_user.unattend @event
    @kind = 'none'
    
    respond_to do |format|
      format.html { redirect_to @event }
      format.json { render :create }
    end
  end
  
  private
    def fetch_rsvp_data
      @event = Event.find_by_id params['event_id']
      @prev_kind = current_user.attendance(@event) || 'none'
    end
end
