require 'spec_helper'

describe PagesController do
  render_views
  
  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end
    
    it 'should have "home" in the title' do
      get 'home'
      response.should have_selector(:title, content: 'home')
    end
    
    describe 'when signed in' do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
        get 'home'
      end
      
      it 'should have a sign out link.' do
        response.should have_selector(:a, content: 'Sign out')
      end
      
      it "should have the current user's name in the header" do
        response.should have_selector(:div, content: @user.name)
      end
    end
    
    describe 'when not signed in' do
      before(:each) do
        get 'home'
      end
      
      it 'should have a sign in link.' do
        response.should have_selector(:a, content: 'Sign in')
      end
      
    end
  end
  
  describe 'GET "about"' do
    it "should be successful" do
      get 'about'
      response.should be_success
    end
    
    it 'should have "What is" in the title' do
      get 'about'
      response.should have_selector(:title, content: 'What is')
    end
  end
  
  describe 'GET search' do
    before :each do
      @user = Factory(:user)
      @poop_user = Factory(:user, name: 'poopyface', uid: Factory.next(:uid),
        email: Factory.next(:email))
      
      @event = Factory(:event)
      @poop_event = Factory(:event, name: "poopslinger's united")
      
      @venue = Factory(:venue, name: Factory.next(:name))
      @poop_venue = Factory(:venue, name: 'poopyland')
      @nincompoop = Factory(:venue, name: Factory.next(:name), 
        description: "The bartender here is a nincompoop.")
    end
    
    it 'should be successful.' do
      get 'search', search: 'poop'
      response.should be_success
    end
    
    it 'should have a user, event, and venue heading.' do
      get 'search', search: 'poop'
      response.should contain '1 Event'
      response.should contain '1 User'
      response.should contain '2 Venues'
    end
    
    it 'should have the right user, event, and venues.' do
      get 'search', search: 'poop'
      response.should contain @poop_user.name
      response.should contain @poop_event.name
      response.should contain @poop_venue.name
      response.should contain @nincompoop.name
    end
    
    it 'should not have the wrong user, event, or venue.' do
      get 'search', search: 'poop'
      response.should_not contain @user.name
      response.should_not contain @event.name
      response.should_not contain @venue.name
    end
  end
end
