require 'spec_helper'

describe Trail do
  before(:each) do
    @user = Factory(:user)
    @target = Factory(:user, email: Factory.next(:email),
      uid: Factory.next(:uid))
    @trail = @user.trails.build(:target_id => @target.id)
  end

  it "should create a new instance given valid attributes" do
    @trail.save!
  end
  
  describe "follow methods" do

    before(:each) do
      @trail.save
    end

    it "should have a tracker attribute" do
      @trail.should respond_to(:tracker)
    end

    it "should have the right tracker" do
      @trail.tracker.should == @user
    end

    it "should have a target attribute" do
      @trail.should respond_to(:target)
    end

    it "should have the right target user" do
      @trail.target.should == @target
    end
  end
  
  describe "validations" do

    it "should require a tracker_id" do
      @trail.tracker_id = nil
      @trail.should_not be_valid
    end

    it "should require a target_id" do
      @trail.target_id = nil
      @trail.should_not be_valid
    end
  end
end
