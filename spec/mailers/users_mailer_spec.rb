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
    
    it "should have an edit preferences link." do
      body = UsersMailer.event_reminder(@user).body
      body.should contain edit_user_url(@user)
    end
    
    describe "with multiple events being attended." do
      before :each do
        @not_today = Factory(:event, name: Factory.next(:name))
        @user.attend @not_today
        @events = [@event]
        2.times do 
          @events << Factory(:event, name: Factory.next(:name),
            date: Date.today)
          @user.attend @events[-1]
        end
        @not_attending = Factory(:event, name: Factory.next(:name),
          date: Date.today)
      end
      
      it "should also include other events today." do
        body = UsersMailer.event_reminder(@user).body
        @events.each do |event|
          body.should contain event.name
          body.should contain event.time
          body.should contain event.address
          body.should contain event.city
        end
      end
      
      it "should not include events that are not today." do
        body = UsersMailer.event_reminder(@user).body
        
        body.should_not contain @not_today.name
        body.should_not contain @not_attending.name
      end
    end
    
    
  end
end
