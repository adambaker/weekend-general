require 'spec_helper'

describe EventAttendee do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event)
    
    @attendee = @user.event_attendees.build(:event_id => @event.id)
  end

  it "should create a new instance given valid attributes" do
    @attendee.save!
  end
  
  describe "attendee methods" do
    before(:each) do
      @attendee.save
    end

    it "should have the right event" do
      @attendee.event.should == @event
    end

    it "should have the right user" do
      @attendee.user.should == @user
    end
  end
  
  describe "validations" do
    it "should require an event_id" do
      @attendee.event_id = nil
      @attendee.should_not be_valid
    end

    it "should require a user_id" do
      @attendee.user_id = nil
      @attendee.should_not be_valid
    end
  end
end
