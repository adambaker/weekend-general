require 'spec_helper'

describe TrailsController do

  describe "access control" do
    it "should require signin for create" do
      post :create, user_id: 1
      response.should redirect_to(sign_in_path)
    end

    it "should require signin for destroy" do
      delete :destroy, user_id: 1, id: 1
      response.should redirect_to(sign_in_path)
    end
  end

  describe "POST 'create'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @target = Factory(:user, Factory.next(:email), Factory.next(:uid))
    end

    it "should blaze a trail" do
      -> do
        post :create, user_id: @target.id
        response.should redirect_to @target
      end.should change(Trail, :count).by(1)
      @user.should be_tracking @target
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
end
