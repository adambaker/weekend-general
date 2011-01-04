require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      name: 'Example User',
      email: 'user@example.com',
      uid: 'foobar',
      provider: 'google'
    }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a name" do
    no_name_user = User.new(@attr.merge(name: ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email" do
    no_email_user = User.new(@attr.merge(email: ""))
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    # Put a user with given email address into the database.
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should require a provider" do
    no_provider_user = User.new(@attr.merge(provider: ""))
    no_provider_user.should_not be_valid
  end
  
  it "should require a uid" do
    no_uid_user = User.new(@attr.merge(uid: ""))
    no_uid_user.should_not be_valid
  end
  
  it "should require unique uid/provider combination" do
    User.create!(@attr)
    user_w_same_provider_uid = User.new(
        @attr.merge(name: 'foo', email:'fake@phony.lie') )
    user_w_same_provider_uid.should_not be_valid
  end
  
  it "should allow same uid with different providers" do
    User.create!(@attr)
    other_user = User.new(name: 'foo', email:'fake@phony.lie', provider: 'foo',
      uid: @attr[:uid])
    other_user.should be_valid
  end
end
