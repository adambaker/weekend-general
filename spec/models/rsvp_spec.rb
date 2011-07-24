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
    
    it "should reject kinds that aren't 'host', 'attend', or 'maybe'." do
      [' ', '', 'foobar', 'unholy example', 'desecrate'].each do |kind|
        @rsvp.kind = kind
        @rsvp.should_not be_valid
      end
    end
  end
  
  describe 'scopes' do
    before(:each) do
      @events  = [];
      @rsvps = [];
      4.times do |i|
        @events << Factory(:event, name: 'event'+i.to_s)
        @rsvps << @user.rsvps.create(event_id: @events[i].id, kind: 'host')
        @rsvps[i].created_at = (5-i).days.ago
      end
      @rsvp.created_at = 10.days.ago
      @rsvp.save
      past_event = Factory(:event, name: Factory.next(:name), 
        date: 10.days.ago)
      @user.rsvps.create(event_id: past_event.id, kind: 'attend')
    end
    
    it 'should have recent rsvps sorted by date.' do
      rsvps = @rsvps.sort {|a,b| b.created_at <=> a.created_at}
      Rsvp.recent.all.should == rsvps
    end
  end
end
