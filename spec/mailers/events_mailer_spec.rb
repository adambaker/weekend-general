require "spec_helper"
require 'set'

describe EventsMailer do
  deliveries = ActionMailer::Base.deliveries
  
  before :each do
    @user = Factory :user
    @event = Factory :event
  end
  
  describe 'new_rsvp' do
    before :each do
      @user.host @event
      @other_user = Factory(:user, email: Factory.next(:email), 
        uid: Factory.next(:uid), name: Factory.next(:name))
      @other_user.attend @event
    end
    
    it "should send user an email." do
      EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').to[0]
        .should =~ /#{@user.email}/
    end
    
    it 'it should be from "weekend.general@gmail.com".' do
      EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').from[0]
        .should =~ /weekend\.general@gmail\.com/
    end
    
    it "should have the other user's name in the subject." do
      EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').subject
        .should =~ /#{@other_user.name}/
    end
    
    it "should have the other user's name and event details in the body." do
      body = EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').body
      body.should contain @other_user.name
      body.should contain @event.name
      body.should contain mail_event_date @event
      body.should contain event_url(@event)
    end
    
    it "should have the user's name and a link to the user's edit page." do
      body = EventsMailer.new_rsvp(@user, @other_user, @event, 'attend').body
      body.should contain @user.name
      body.should contain edit_user_url(@user)
    end
    
    it "should deliver the message." do
      -> {EventsMailer.new_rsvp(@user, @other_user, @event, 'attend')}
        .should change(deliveries, :size).by 1
    end
    
    it "should not deliver to the same user that rsvp'd." do
      -> {EventsMailer.new_rsvp(@other_user, @other_user, @event, 'attend')}
        .should_not change(deliveries, :size)
    end
  end
  
  describe 'all_new_rsvp' do
    before :each do
      @host_no = Factory(:user, uid: Factory.next(:uid), host_rsvp: false,
        email: Factory.next(:email))
      @host_no.host @event
      @host = Factory(:user, uid: Factory.next(:uid), 
        email: Factory.next(:email))
      @host.host @event
      
      @attend_no = Factory(:user, email: Factory.next(:email), host_rsvp: false,
        uid: Factory.next(:uid))
      @attend_no.attend @event
      @attend = Factory(:user, uid: Factory.next(:uid), attend_rsvp: true, 
        email: Factory.next(:email), host_rsvp: false )
      @attend.attend @event
      
      @maybe_no = Factory(:user, email: Factory.next(:email),
        uid: Factory.next(:uid), host_rsvp: false )
      @maybe_no.maybe @event
      @maybe = Factory(:user, uid: Factory.next(:uid), host_rsvp: false,
        email: Factory.next(:email), maybe_rsvp: true)
      @maybe.maybe @event
      
      @user.host @event
    end
    
    it "should send out 3 emails." do
      ->{EventsMailer.all_new_rsvp(@user, @event, 'host')}
        .should change(deliveries, :size).by 3
    end
    
    it 'should deliver them to host, attend, and maybe' do
      deliveries.clear
      EventsMailer.all_new_rsvp(@user, @event, 'host')
      to_addresses = deliveries.map{|m| m.to[0]}.to_set
      to_addresses.should == [@host, @attend, @maybe].map{|u| u.email}.to_set
    end
  end
  
  describe 'new_event' do
    before :each do
      @user.new_event = true
      @user.save
    end
    
    it "should send user an email." do
      EventsMailer.new_event(@user, @event).to[0].should =~ /#{@user.email}/
    end
    
    it "should have the event details in the body." do
      body = EventsMailer.new_event(@user, @event).body
      body.should contain @event.name
      body.should contain mail_event_date @event
      body.should contain event_url(@event)
    end
    
    it "should send the message" do
      ->{EventsMailer.new_event(@user, @event)}
        .should change(deliveries, :size).by 1
    end
    
    it 'should not send the event if the user created it.' do
      @event.created_by = @user.id
      @event.save
      ->{EventsMailer.new_event(@user, @event)}
        .should_not change(deliveries, :size)
    end
  end
  
  describe 'all_new_event' do
    before :each do
      @other_user = Factory(:user, uid: Factory.next(:uid), new_event: true,
        email: Factory.next(:email))
    end
    
    it 'should send out one email.' do
      ->{EventsMailer.all_new_event(@event)}
        .should change(deliveries, :size).by 1
    end
    
    it 'should send @other_user the email.' do
      deliveries.clear
      EventsMailer.all_new_event(@event)
      deliveries[0].to.size.should == 1
      deliveries[0].to[0].should =~ /#{@other_user.email}/
    end
  end
end
