require 'spec_helper'

describe EventHost do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event)
    
    @host = @user.event_hosts.build(:event_id => @event.id)
  end

  it "should create a new instance given valid attributes" do
    @host.save!
  end
  
  describe "host methods" do
    before(:each) do
      @host.save
    end

    it "should have the right event" do
      @host.event.should == @event
    end

    it "should have the right user" do
      @host.user.should == @user
    end
  end
  
  describe "validations" do
    it "should require an event_id" do
      @host.event_id = nil
      @host.should_not be_valid
    end

    it "should require a user_id" do
      @host.user_id = nil
      @host.should_not be_valid
    end
  end
end
