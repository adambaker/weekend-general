class RsvpsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_event

  def create
    current_user.send params['kind'], @event
    UsersMailer.notify_trackers(current_user, @event, params['kind'])
    EventsMailer.all_new_rsvp(current_user, @event, params['kind'])
    redirect_to @event
  end
  
  def destroy
    current_user.unattend @event
    redirect_to @event
  end
  
  def fetch_event
    @event = Event.find_by_id params['event_id']
  end
end
