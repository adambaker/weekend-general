require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      name: 'Example User',
      email: 'user@example.com',
      uid: 'foobar',
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
      @past_event = Factory(:event, name: Factory.next(:name), date: 1.day.ago)
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
    
    it "should default to 1" do
      User.create(@attr).rank.should == 1
    end
    
    it "should allow users to be promoted." do
      user = User.create(@attr)
      user.promote
      user.rank.should == 2
    end
    
    it "should promote users in the majors list to rank 4" do
      User.create(@attr.merge(email: Settings::majors[0])).rank.should == 4
    end
  end
end
