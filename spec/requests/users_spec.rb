require 'spec_helper'

describe "Users" do
  before :each do
    @officer = Factory :user
    set_rank(@officer, 4)
    @venue = Factory :venue
    @event = Factory :event
    @attr = 
      {
        name: 'Terrible deep', 
        email: 'never@publish.me', 
        provider: 'google',
        uid: 'alwaysandfornever.fool',
        description: 'I never want to die but always fear I will.'
      }
    integration_new_user @attr
  end
  
  it "should log off a logged in user who is discharged." do
    visit event_path(@event)
    response.should be_success
    response.should contain("Signed in as #{@attr[:name]}")
    
    discharge = DishonorableDischarge.new(
      user_id: User.find_by_email(@attr[:email]).id,
      reason:   'never again',
    )
    discharge.officer_id = @officer.id;
    discharge.save!

    visit venue_path(@venue)
    response.should_not contain("Signed in as #{@attr[:name]}")
  end
end
