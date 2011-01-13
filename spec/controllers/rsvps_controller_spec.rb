require 'spec_helper'

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
      lambda do
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
      lambda do
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
end
