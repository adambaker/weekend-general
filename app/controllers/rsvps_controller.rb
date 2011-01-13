class RsvpsController < ApplicationController
  before_filter :authenticate

  def create
    event = Event.find_by_id params['event_id']
    current_user.send params['kind'], event
    redirect_to event
  end
  
  def destroy
    event = Event.find_by_id params['event_id']
    current_user.unattend event
    redirect_to event
  end
  
end
