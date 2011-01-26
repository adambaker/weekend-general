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
      
      it "should not include events that are not today or the user is not attending." do
        body = UsersMailer.event_reminder(@user).body
        
        body.should_not contain @not_today.name
        body.should_not contain @not_attending.name
      end
      
      describe "maybe and hosting events" do
        before :each do 
          @user.maybe @event
          @user.host @events[-1]
        end
        
        it "should not include events the user has rsvp'd maybe or host to." do
          body = UsersMailer.event_reminder(@user).body
          
          body.should_not contain @event.name
          body.should_not contain @events[-1].name
        end
        
        it "should include maybe events if user.maybe_reminder is set." do
          @user.maybe_reminder = true
          @user.save
          body = UsersMailer.event_reminder(@user).body
          
          body.should contain @event.name
          body.should_not contain @events[-1].name
        end
        
        it "should include host events if user.host_reminder is set." do
          @user.host_reminder = true
          @user.save
          body = UsersMailer.event_reminder(@user).body
          
          body.should contain @events[-1].name
          body.should_not contain @event.name
        end
        
        it "should not include attended events if user.attend_reminder is false." do
          @user.attend_reminder = false
          @user.save
          body = UsersMailer.event_reminder(@user).body
          
          @events[1...-1].each do |event|
            body.should_not contain event.name
          end
        end
      end
    end
    
    describe "delivery" do
      it "should deliver the message." do
        -> {UsersMailer.event_reminder(@user)}
          .should change(ActionMailer::Base.deliveries, :size).by 1
      end
      
      it "should not deliver any message if there are no events." do
        @user.host @event
        -> {UsersMailer.event_reminder(@user)}
          .should_not change(ActionMailer::Base.deliveries, :size)
      end
    end
  end
  
  describe "send_all_reminders" do
    before :each do
      @users = [@user]
      4.times{@users << Factory(:user, name: Factory.next(:name), 
        uid: Factory.next(:uid), email: Factory.next(:email))}
      @events = [Factory(:event, date: Date.today)]         
      2.times{@events << Factory(:event, name: Factory.next(:name), 
        date: Date.today)}
      @not_today = Factory(:event, name: Factory.next(:name))
      
      #@user should not get an email
      @user.host @events[0]
      @user.maybe @events[1]
      @user.attend @not_today
      
      #@users[1] should get an email
      @users[1].maybe @events[0]
      @users[1].attend @events[1]
      
      #@users[2] should not get an email
      @users[2].attend_reminder = false
      @users[2].save
      @users[2].attend @events[0]
      @users[2].host @events[1]
      @users[2].maybe @events[2]
      
      #@users[3] should not get an email because he's not doing anything
      
      #@users[4] should get an email
      @users[4].maybe @events[0]
      @users[4].maybe_reminder = true
      @users[4].save
    end
    
    it "should only send out 2 emails." do
      ->{UsersMailer.send_all_reminders}
        .should change(ActionMailer::Base.deliveries, :size).by 2
    end
    
    it "should send those emails to the right users." do
      UsersMailer.send_all_reminders
      first, second = ActionMailer::Base.deliveries
      if first.to[0] =~ /#{@users[1].email}/
        second.to[0].should =~ /#{@users[4].email}/
      else
        first.to[0].should =~ /#{@users[4].email}/
        second.to[0].should =~ /#{@users[1].email}/
      end
    end
  end
  
  def 
end
