require 'spec_helper'

describe Rsvp do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event)
    
    @rsvp = @user.rsvps.build(event_id: @event.id, kind: 'host')
  end

  it "should create a new instance given valid attributes" do
    @rsvp.save!
  end
  
  describe "rsvp methods" do
    before(:each) do
      @rsvp.save
    end

    it "should have the right event" do
      @rsvp.event.should == @event
    end

    it "should have the right user" do
      @rsvp.user.should == @user
    end
    
    it "should have the right kind" do
      @rsvp.kind.should == 'host'
    end
  end
  
  describe "validations" do
    it "should require an event_id" do
      @rsvp.event_id = nil
      @rsvp.should_not be_valid
    end

    it "should require a user_id" do
      @rsvp.user_id = nil
      @rsvp.should_not be_valid
    end
    
    it "should require a kind" do
      @rsvp.kind = ''
      @rsvp.should_not be_valid
    end
  end
end
