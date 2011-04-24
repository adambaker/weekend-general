require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      name: 'Example User',
      email: 'fake@example.com',
      uid: 'punchbucket',
      provider: 'google',
      description: venue_attr[:description],
      theme: 'general'
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(name: ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email" do
    no_email_user = User.new(@attr.merge(email: ""))
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should require a provider" do
    no_provider_user = User.new(@attr.merge(provider: ""))
    no_provider_user.should_not be_valid
  end
  
  it "should require a uid" do
    no_uid_user = User.new(@attr.merge(uid: ""))
    no_uid_user.should_not be_valid
  end
  
  it "should require unique uid/provider combination" do
    User.create!(@attr)
    user_w_same_provider_uid = User.new(
        @attr.merge(name: 'foo', email:'fake@phony.lie') )
    user_w_same_provider_uid.should_not be_valid
  end
  
  it "should allow same uid with different providers." do
    User.create!(@attr)
    other_user = User.new(name: 'foo', email:'fake@phony.lie', provider: 'foo',
      uid: @attr[:uid])
    other_user.should be_valid
  end
  
  it "should have a description." do
    User.create!(@attr).should respond_to(:description)
  end
  
  it "should have a theme." do
    User.create!(@attr).should respond_to(:theme)
  end
  
  it "should default to 'general' theme." do
    User.new.theme.should == 'general'
  end
  
  it "should accept themes in Themes::THEMES." do
    Themes::THEMES.keys.each do |theme|
      User.new(@attr.merge(theme: theme)).should be_valid
    end
  end
  
  it "should reject any themes not in Themes::THEMES." do
    ['//aioeu', ' ', 'not a theme name', "Don't name a theme this"].each do |w|
      User.new(@attr.merge(theme: w)).should_not be_valid
    end
  end
  
  describe "event attendance" do
    before :each do
      @user = User.create(@attr)
      @events = [Factory(:event)]
      5.times { @events << Factory(:event, name: Factory.next(:name)) }
      @past_event = Factory(:event, name: Factory.next(:name), 
        date: 1.day.ago.beginning_of_day)
    end
    
    describe "hosting" do
      before :each do
        @events.each do |event|
          @user.host event
        end
      end
      
      it "should track which events a user is hosting." do
        @user.hosting.should == @events
      end
      
      it "should let a user unhost an event." do
        @user.unattend @events[0]
        @user.hosting.should_not include(@events[0])
      end
      
      it "should not show past events." do
        @user.host @past_event
        @user.hosting.should_not include(@past_event)
      end
    end
    
    describe "attending" do
      before :each do
        @events.each do |event|
          @user.attend event
        end
      end
      
      it "should track which events a user is attending." do
        @user.attending.should == @events
      end
      
      it "should let a user unattend an event." do
        @user.unattend @events[0]
        @user.attending.should_not include(@events[0])
      end
      
      it "should not show past events." do
        @user.attend @past_event
        @user.attending.should_not include(@past_event)
      end
    end

    describe "maybe" do
      before :each do
        @events.each do |event|
          @user.maybe event
        end
      end
      
      it "should track which events a user may be attending." do
        @user.maybes.should == @events
      end
      
      it "should let a user unmaybe an event." do
        @user.unattend @events[0]
        @user.maybes.should_not include(@events[0])
      end
      
      it "should not show past events." do
        @user.maybe @past_event
        @user.maybes.should_not include(@past_event)
      end
    end
    
    it "should not duplicate an rsvp when multiple users RSVP to an event." do
      @user.maybe @events[0]
      other_user = Factory(:user, name: Factory.next(:name), 
        email: Factory.next(:email), uid: Factory.next(:uid))
      other_user.maybe @events[0]
      
      @user.maybes.all.map{|e| e.name}.should == 
        [@events[0]].map{|e| e.name}
      other_user.maybes.all.map{|e| e.name}.should == 
        [@events[0]].map{|e| e.name}
    end
    
    describe "combinations" do
      before :each do
        @user.host @events[0]
        @user.host @events[1]
        @user.attend @events[2]
        @user.attend @events[3]
        @user.maybe @events[4]
        @user.maybe @events[5]
      end
      
      it "should have the right event associations." do
        @user.hosting.should include(@events[0])
        @user.hosting.should include(@events[1])
        @user.attending.should include(@events[2])
        @user.attending.should include(@events[3])
        @user.maybes.should include(@events[4])
        @user.maybes.should include(@events[5])
        @user.events.should == @events
      end
      
      it "should delete associations when the user is destroyed." do
        id = @user.id
        @user.destroy
        Rsvp.find_by_user_id(id).should be_nil
      end
    end
  end
  
  describe "rank" do
   
    it "should allow users to be promoted." do
      user = User.create(@attr)
      user.promote
      user.rank.should == 2
    end
    
    it "should promote users in the majors list to rank 4." do
      User.create(@attr.merge(email: Settings::majors[0])).rank.should == 4
    end
    
    it "should have rank 3 and 4 users in officers." do
      users = []
      4.times do |i|
        users << Factory(:user, email: Factory.next(:email), 
          uid: Factory.next(:uid))
        users[i].rank = i+1
        users[i].save
      end
      officers = User.officers
      officers.should include(users[3])
      officers.should include(users[2])
      officers.should_not include(users[1])
      officers.should_not include(users[0])
    end
  end
    
  describe "tracking" do

    before(:each) do
      @user = User.create!(@attr)
      @target = Factory(:user)
    end

    it "should have a trails method" do
      @user.should respond_to :trails
    end
    
    it "should have a targets method" do
      @user.should respond_to :targets
    end
    
    it "should track another user" do
      @user.track @target
      @user.should be_tracking @target
    end

    it "should include the targeted user in the targets array" do
      @user.track @target
      @user.targets.should include @target
    end

    it "should untrack a user" do
      @user.track @target
      @user.untrack @target
      @user.should_not be_tracking @target
    end
    
    it "should have a breadcrumbs method" do
      @user.should respond_to :breadcrumbs
    end

    it "should have a trackers method" do
      @user.should respond_to :trackers
    end

    it "should include the follower in the followers array" do
      @user.track @target
      @target.trackers.should include(@user)
    end
    
    it "should destroy the user's trails when the user is destroyed." do
      @user.track @target
      id = @user.id
      @user.destroy
      Trail.find_by_tracker_id(id).should be_nil
    end
    
    it "should destroy the user's breadcrumbs when the user is destroyed." do
      @user.track @target
      id = @target.id
      @target.destroy
      Trail.find_by_target_id(id).should be_nil
    end
  end
  
  describe "defaults" do
    {
      attend_reminder: true, maybe_reminder: false, host_reminder: false,
      track_host: true, track_attend: true, track_maybe: false,
      host_rsvp: true, attend_rsvp: false, maybe_rsvp: false,
      new_event: false, rank: 1
    }.each do |name, value|
      it "should have #{name.to_s} default to #{value.to_s}." do
        User.create(@attr).send(name).should == value
      end
    end
  end
  
  describe "search" do
    before :each do
      @user = Factory :user
      @poop = Factory(:user, name: 'poopyface', uid: Factory.next(:uid), 
        email: Factory.next(:email))
      @nincompoop = Factory(:user, name: 'John Nincompoop', 
        uid: Factory.next(:uid), email: Factory.next(:email))
      @cellar = Factory(:user, uid: Factory.next(:uid),
        email: Factory.next(:email), description: 'Help me escape the cellar!')
    end
    
    it "should not contain @user or @cellar." do
      User.search('poop').should_not include(@user)
      User.search('poop').should_not include(@cellar)
    end
    
    it "should contain @poop and @nincompoop." do
      poop = User.search('poop')
      poop.should include(@poop)
      poop.should include(@nincompoop)
      poop.size.should == 2
    end
    
    it "should contain @cellar when searching 'cellar'" do
      cellar = User.search('cellar')
      cellar.should include(@cellar)
      cellar.size.should == 1
    end
  end
  
  describe "target_rsvps" do
    before :each do
      @user = Factory :user
      @target1 = User.create! @attr
      @target2 = Factory(:user, uid: Factory.next(:uid), 
        email: Factory.next(:email))
      @non_target = Factory(:user, uid: Factory.next(:uid), 
        email: Factory.next(:email))
      @user.track @target1
      @user.track @target2
      @event = Factory :event
      @event2 = Factory(:event, name: Factory.next(:name))
      @old_rsvp = @target1.attend @event
      @old_rsvp.created_at = 10.days.ago
      @old_rsvp.save
      @rsvps = []
      @rsvps << @target1.attend(@event2)
      @rsvps << @target2.maybe(@event)
      @rsvps << @target2.host(@event2)
      @non_target.attend @event
    end
    
    it "should not include old rsvps or untracked users rsvps." do
      target_rsvps = @user.target_rsvps
      target_rsvps.size.should == @rsvps.size
      target_rsvps.each do |rsvp|
        @rsvps.should include rsvp
      end
    end
  end
end
