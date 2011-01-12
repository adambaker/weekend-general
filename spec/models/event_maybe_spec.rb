require 'spec_helper'

describe EventMaybe do
  before(:each) do
    @user = Factory(:user)
    @event = Factory(:event)
    
    @maybe = @user.event_maybes.build(:event_id => @event.id)
  end

  it "should create a new instance given valid attributes" do
    @maybe.save!
  end
  
  describe "maybe methods" do
    before(:each) do
      @maybe.save
    end

    it "should have the right event" do
      @maybe.event.should == @event
    end

    it "should have the right user" do
      @maybe.user.should == @user
    end
  end
  
  describe "validations" do
    it "should require an event_id" do
      @maybe.event_id = nil
      @maybe.should_not be_valid
    end

    it "should require a user_id" do
      @maybe.user_id = nil
      @maybe.should_not be_valid
    end
  end
end
