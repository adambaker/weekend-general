require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      name: 'Example User',
      email: 'user@example.com',
      password: 'foobar',
      password_confirmation: 'foobar'
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
  
  it 'should require a valid email' do
    bad_email_user = User.new(@attr.merge(email: 'email@foo'))
    bad_email_user.should_not be_valid
    bad_email_user = User.new(@attr.merge(email: 'email.com'))
    bad_email_user.should_not be_valid
  end
  
end
