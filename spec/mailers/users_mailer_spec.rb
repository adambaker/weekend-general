require "spec_helper"

describe UsersMailer do
  before :each do
    @user = Factory :user
  end
  
  describe "event_reminder" do
    before :each do
      @event = Factory(:event, date: Date.today)
      @user.attend @event
    end
    
    it "should create an email." do
      UsersMailer.event_reminder(@user).should_not be_nil
    end
    
    it "should have the the user's email as the to address." do
      UsersMailer.event_reminder(@user).to.should == [@user.email]
    end
    
    it "should be from 'weekend.general@gmail.com'." do
      UsersMailer.event_reminder(@user).from.should == 
        ['weekend.general@gmail.com']
    end
    
    it "should have user's name and event's name and time in the body." do
      body = UsersMailer.event_reminder(@user).body
      body.should contain @user.name
      body.should contain @event.name
      body.should contain @event.time
      body.should contain @event.address
      body.should contain @event.city
    end
    
    it "should have the event's name in the subject." do
      UsersMailer.event_reminder(@user).subject.should =~ /#{@event.name}/
    end
  end
end
