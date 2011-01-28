require 'spec_helper'
require 'set'

describe RsvpsController do
  describe "access control" do
  
    it "should require signin for create" do
      post :create, event_id: 1
      response.should redirect_to(sign_in_path)
    end

    it "should require signin for destroy" do
      delete :destroy, event_id: 1, id: 1
      response.should redirect_to(sign_in_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @event = Factory(:event)
    end

    it "should create an rsvp" do
      -> do
        post :create, event_id: @event.id, kind: 'host'
        response.should redirect_to @event
      end.should change(Rsvp, :count).by(1)
    end
    
    #it "should create an rsvp using Ajax" do
    #  lambda do
    #    xhr :post, :create, event_id: event.id, kind: 'host'
    #    response.should be_success
    #  end.should change(Rsvp, :count).by(1)
    #end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @event = Factory(:event)
      @user.host @event
      @rsvp = @user.rsvps.find_by_event_id(@event)
    end

    it "should destroy an rsvp" do
      -> do
        delete :destroy, event_id: @event.id, kind: 'host', id: @rsvp.id
        response.should redirect_to @event
      end.should change(Rsvp, :count).by(-1)
    end
    
    
    #it "should destroy an rsvp using Ajax" do
    #  lambda do
    #    xhr :delete, :destroy, id: @rsvp
    #    response.should be_success
    #  end.should change(Rsvp, :count).by(-1)
    #end
  end
  
  describe 'user notifications' do
    before :each do
      @user = test_sign_in(Factory(:user))
      @event = Factory :event
      
      @host_tracker = Factory(:user, uid: Factory.next(:uid), 
        email: Factory.next(:email), track_host: true, track_attend: false,
        track_maybe: false)
      @attend_tracker = Factory(:user, uid: Factory.next(:uid), 
        email: Factory.next(:email), track_host: false, track_attend: true,
        track_maybe: false, host_rsvp: false, attend_rsvp: true)
      @maybe_tracker = Factory(:user, uid: Factory.next(:uid), 
        email: Factory.next(:email), track_host: false, track_attend: false,
        track_maybe: true, host_rsvp: false, maybe_rsvp: true)
      @deliveries = ActionMailer::Base.deliveries.clear
    end
    
    describe 'user tracking emails' do
      before :each do
        @host_tracker.track @user
        @attend_tracker.track @user
        @maybe_tracker.track @user
      end
      
      it "should send host tracker an email when user hosts" do
        post :create, event_id: @event.id, kind: 'host'
        @deliveries.size.should == 1
        @deliveries[0].to.size.should == 1
        @deliveries[0].to[0].should =~ /#{@host_tracker.email}/
      end
      
      it "should send attend tracker an email when user attends" do
        post :create, event_id: @event.id, kind: 'attend'
        @deliveries.size.should == 1
        @deliveries[0].to.size.should == 1
        @deliveries[0].to[0].should =~ /#{@attend_tracker.email}/
      end
      
      it "should send maybe tracker an email when user says maybe" do
        post :create, event_id: @event.id, kind: 'maybe'
        @deliveries.size.should == 1
        @deliveries[0].to.size.should == 1
        @deliveries[0].to[0].should =~ /#{@maybe_tracker.email}/
      end
    end
    
    describe "rsvp'd user emails." do
      before :each do
        @host_tracker.host @event
        @attend_tracker.attend @event
        @maybe_tracker.maybe @event
      end
      
      it 'should send each an email' do
        post :create, event_id: @event.id, kind: 'maybe'
        @deliveries.map{|m| m.to[0]}.to_set.should ==
          [@host_tracker, @attend_tracker, @maybe_tracker]
            .map{|u| u.email}.to_set
      end
      
      it 'should not send host_tracker an email when not hosting.' do
        @host_tracker.attend @event
        post :create, event_id: @event.id, kind: 'maybe'
        @deliveries.map{|m| m.to[0]}.should_not include(@host_tracker.email)
      end
      
      it 'should not send attend_tracker an email when not attending.' do
        @attend_tracker.maybe @event
        post :create, event_id: @event.id, kind: 'maybe'
        @deliveries.map{|m| m.to[0]}.should_not include(@attend_tracker.email)
      end
      
      it 'should not send maybe_tracker an email when not maybe.' do
        @maybe_tracker.attend @event
        post :create, event_id: @event.id, kind: 'maybe'
        @deliveries.map{|m| m.to[0]}.should_not include(@maybe_tracker.email)
      end
    end
  end
end
