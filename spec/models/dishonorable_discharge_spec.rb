require 'spec_helper'

describe DishonorableDischarge do
  before :each do
    @officer = Factory :user
    @officer.rank = 4
    @officer.save!
    @attr = {
      email: 'fake@phony.lie',
      provider: 'nobody',
      uid: 'impossible',
      officer: @officer.id,
      reason: 'ruined everything'
    }
  end

  it "should create a new discharge given valid attributes" do
    DishonorableDischarge.create!(@attr)
  end

  it "should require a reason" do 
    no_reason = DishonorableDischarge.new(@attr.merge(reason: ''))
    no_reason.should_not be_valid
  end

  it "should require an email" do
    no_email = DishonorableDischarge.new(@attr.merge(email: ''))
    no_email.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email = DishonorableDischarge.new(@attr.merge(:email => address))
      valid_email.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email = DishonorableDischarge.new(@attr.merge(:email => address))
      invalid_email.should_not be_valid
    end
  end

  it "should require a provider" do
    no_provider = DishonorableDischarge.new(@attr.merge(provider: ''))
    no_provider.should_not be_valid
  end

  it "should require a uid" do
    no_uid = DishonorableDischarge.new(@attr.merge(uid: ''))
    no_uid.should_not be_valid
  end

end
