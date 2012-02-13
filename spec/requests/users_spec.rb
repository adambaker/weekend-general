require 'spec_helper'

describe "Users" do
  #before :each do
  #  @officer = Factory :user
  #  set_rank(@officer, 4)
  #  @venue = Factory :venue
  #  @event = Factory :event
  #  @attr = 
  #    {
  #      name: 'Terrible deep', 
  #      email: 'never@publish.me', 
  #      provider: 'google',
  #      uid: 'alwaysandfornever.fool',
  #      description: 'I never want to die but always fear I will.'
  #    }
  #  integration_new_user @attr
  #end
  #
  #it "should log off a logged in user who is discharged." do
  #  visit event_path(@event)
  #  response.should be_success
  #  response.should contain("Signed in as #{@attr[:name]}")
  #  
  #  DishonorableDischarge.create!(
  #    email:    @attr[:email],
  #    provider: @attr[:provider],
  #    uid:      @attr[:uid],
  #    officer:  @officer.id,
  #    reason:   'never again',
  #  )

  #  visit venue_path(@venue)
  #  response.should_not contain("Signed in as #{@attr[:name]}")
  #end
end
