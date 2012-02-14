require 'spec_helper'

describe DishonorableDischarge do
  before :each do
    @officer = Factory :user
    @officer.rank = 4
    @officer.save!
    @user = Factory(:user, 
                    email: Factory.next(:email),
                    uid:   Factory.next(:uid),
                    name:  Factory.next(:name),
                   )
    @discharge = DishonorableDischarge.new(
      user_id: @user.id,
      reason: 'ruined everything'
    )
    @discharge.officer_id = @officer.id
  end

  it "should create a new discharge given valid attributes" do
    @discharge.save!
  end

  it "should require a reason" do 
    @discharge.reason = ''
    @discharge.should_not be_valid
  end

  it 'should require a user' do
    @discharge.user_id = nil
    @discharge.should_not be_valid
  end

  it "should require an officer" do
    @discharge.officer_id = nil
    @discharge.should_not be_valid
  end

  it "should require the officer have officer rank" do
    other_user = Factory(:user, 
                    email: Factory.next(:email),
                    uid:   Factory.next(:uid),
                    name:  Factory.next(:name),
                   )
    @discharge.officer_id = other_user.id
    @discharge.should_not be_valid
  end

  describe 'relationships' do
    before :each do
      @discharge.save!
    end

    it 'should have the discharged user' do
      @discharge.user.should == @user
    end

    it 'should mark the user as discharged' do
      #find the user to ensure discharged status is saved in the db
      User.unscoped.find(@user.id).should be_discharged
    end

    it 'should have the discharging officer' do
      @discharge.officer.should == @officer
    end
  end

end
