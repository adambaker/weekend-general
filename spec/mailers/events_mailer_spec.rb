require "spec_helper"

describe EventsMailer do
  before :each do
    @user = Factory :user
  end
  
  describe 'new_rsvp' do
    before :each do
      @event = Factory :event
      @user.host @event
      @other_user = Factory(:user, email: Factory.next(:email), 
        uid: Factory.next(:uid), name: Factory.next(:name))
      @other_user.attend @event
    end
    
    it "should send user an email." do
      EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').to[0]
        .should =~ /#{@user.email}/
    end
    
    it 'it should be from "weekend.general@gmail.com".' do
      EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').from[0]
        .should =~ /weekend\.general@gmail\.com/
    end
    
    it "should have the other user's name in the subject." do
      EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').subject
        .should =~ /#{@other_user.name}/
    end
    
    it "should have the other user's name and event details in the body." do
      body = EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').body
      body.should contain @other_user.name
      body.should contain @event.name
      body.should contain mail_event_date @event
      body.should contain event_url(@event)
    end
    
    it "should have the user's name and a link to the user's edit page." do
      body = EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').body
      body.should contain @user.name
      body.should contain edit_user_url(@user)
    end
    
    it "should deliver the message." do
      -> {EventsMailer.new_rsvp(@user, @other_user, @event, 'attend')}
        .should change(ActionMailer::Base.deliveries, :size).by 1
    end
    
    it "should not deliver to the same user that rsvp'd." do
      -> {EventsMailer.new_rsvp(@other_user, @other_user, @event, 'attend')}
        .should_not change(ActionMailer::Base.deliveries, :size)
    end
  end
  
  describe 'new_event' do
  
  end
end
