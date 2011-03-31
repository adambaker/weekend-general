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
      @target = Factory(:user, email: Factory.next(:email), 
        uid: Factory.next(:uid))
    end

    it "should blaze a trail" do
      -> do
        post :create, user_id: @target.id
        response.should redirect_to @target
      end.should change(Trail, :count).by(1)
      @user.should be_tracking @target
    end
    
    it "should create a trail using Ajax" do
      lambda do
        xhr :post, :create, user_id: @target.id, format: :json
        response.should be_success
      end.should change(Trail, :count).by(1)
      @user.should be_tracking @target
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = test_sign_in(Factory(:user))
      @target = Factory(:user, email: Factory.next(:email),
        uid: Factory.next(:uid))
      @user.track @target
      @trail = @user.trails.find_by_target_id(@target.id)
    end

    it "should destroy a trail" do
      -> do
        delete :destroy, user_id: @target.id, id: @trail.id
        response.should redirect_to @target
      end.should change(Trail, :count).by(-1)
      @user.should_not be_tracking @target
    end
    
    
    it "should destroy a trail using Ajax" do
      -> do
        xhr :delete, :destroy, id: @trail, user_id: @target.id, format: :json
        response.should be_success
      end.should change(Trail, :count).by(-1)
      @user.should_not be_tracking @target
    end
  end
end
