require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      name: 'Example User',
      email: 'user@example.com',
      uid: 'foobar',
      provider: 'google'
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
  
  it "should allow same uid with different providers" do
    User.create!(@attr)
    other_user = User.new(name: 'foo', email:'fake@phony.lie', provider: 'foo',
      uid: @attr[:uid])
    other_user.should be_valid
  end
  
  describe "admin privileges" do
    before :each do
      @user = User.create(@attr)
      @admin_users = []
      WeekendGeneral::Local.admins.each do |email|
        @admin_users << User.create(@attr.merge(
          email: email, uid: Factory.next(:uid)) )
      end
    end
    
    it "should have an admin attribute." do
      @user.should respond_to :admin
    end
    
    it "should default to not being admin." do
      @user.should_not be_admin
    end
    
    it "should make users listed as admins in the config administrators." do
      @admin_users.each do |admin|
        admin.should be_admin
      end
    end
  end
  
  describe "event attendance" do
    before :each do
      @user = User.create(@attr)
      @events = [Factory(:event)]
      5.times { @events << Factory(:event, name: Factory.next(:name)) }
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
end
