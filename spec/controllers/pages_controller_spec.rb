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
      get 'search', search: 'poop', event: '1', user: '1', venue: '1', 
        when: 'future', price: 'any'
      response.should contain '1 Event'
      response.should contain '1 User'
      response.should contain '2 Venues'
    end
    
    it 'should have the right user, event, and venues.' do
      get 'search', search: 'poop', event: '1', user: '1', venue: '1', 
        when: 'future', price: 'any'
      response.should contain @poop_user.name
      response.should contain @poop_event.name
      response.should contain @poop_venue.name
      response.should contain @nincompoop.name
    end
    
    it 'should not have the wrong user, event, or venue.' do
      get 'search', search: 'poop', event: '1', user: '1', venue: '1', 
        when: 'future', price: 'any'
      response.should_not contain @user.name
      response.should_not contain @event.name
      response.should_not contain @venue.name
    end
    
    it 'should only have users when only user is checked.' do
      get 'search', search: 'poop', user: '1', when: 'future', price: 'any'
      response.should_not contain @poop_event.name
      response.should_not contain @nincompoop.name
      response.should_not contain @poop_venue.name
      response.should_not contain '1 Event'
      response.should_not contain '2 Venues'
      response.should contain '1 User'
      response.should contain @poop_user.name
    end
    
    it 'should only have venues when only venue is checked.' do
      get 'search', search: 'poop', venue: '1', when: 'future', price: 'any'
      response.should_not contain @poop_event.name
      response.should_not contain @poop_user.name
      response.should_not contain '1 Event'
      response.should_not contain '1 User'
      response.should contain @nincompoop.name
      response.should contain @poop_venue.name
      response.should contain '2 Venues'
    end
    
    it 'should only have events when only event is checked.' do
      get 'search', search: 'poop', event: '1', when: 'future', price: 'any'
      response.should_not contain @poop_user.name
      response.should_not contain @nincompoop.name
      response.should_not contain @poop_venue.name
      response.should_not contain '1 User'
      response.should_not contain '2 Venues'
      response.should contain '1 Event'
      response.should contain @poop_event.name
    end
    
    describe "event filters" do
      before :each do
        @event.price = '10'
        @event.date = Time.zone.today
        @event.save
        @poop_event.price = '0'
        @poop_event.save
        @expensive = Factory(:event, name: Factory.next(:name))
        @expensive.price = '40'
        @expensive.save
      end
      
      it "should only show free events when free is chosen." do
        get 'search', search: '', event: '1', when: 'future', price: 'free'
        response.should contain @poop_event.name
        response.should_not contain @expensive.name
        response.should_not contain @event.name
      end
      
      it "should not show the expensive event when < 30 is chosen." do
        get 'search', search: '', event: '1', when: 'future', price: 'less',
          price_text: '30'
        response.should contain @poop_event.name
        response.should contain @event.name
        response.should_not contain @expensive.name
      end
      
      it "should not have @event when < 5 is chosen." do
        get 'search', search: '', event: '1', when: 'future', price: 'less',
          price_text: '5'
        response.should contain @poop_event.name
        response.should_not contain @expensive.name
        response.should_not contain @event.name
      end
      
      it "should only have @event if 'when' is 'today'." do
        get 'search', search: '', event: '1', when: 'today'
        response.should contain @event.name
        response.should_not contain @poop_event.name
        response.should_not contain @expensive.name
      end
      
      it "should not have past events when future is selected." do
        @event.date = 2.days.ago
        @event.save
        get 'search', search: '', event: '1', when: 'future'
        response.should contain @poop_event.name
        response.should contain @expensive.name
        response.should_not contain @event.name
      end
      
      it "should not have distant events when this_week is selected." do
        @event.date = 10.days.from_now
        @event.save
        get 'search', search: '', event: '1', when: 'week'
        response.should contain @poop_event.name
        response.should contain @expensive.name
        response.should_not contain @event.name
      end
      
      it "should have the same settings as the request in the form." do
        get 'search', search: 'talent', event: '1', user: '1', when: 'today',
          price: 'any'
        response.should have_selector :input, type: 'text', value: 'talent'
        response.should have_selector :input, type: 'checkbox', name: 'event',
          checked: 'checked'
        response.should have_selector :input, type: 'checkbox', name: 'user',
          checked: 'checked'
        response.should_not have_selector :input, type: 'checkbox', 
          name: 'venue', checked: 'checked'
        response.should have_selector :input, type: 'radio', name: 'when',
          value: 'today', checked: 'checked'
        response.should have_selector :input, type: 'radio', name: 'price',
          value: 'any', checked: 'checked'
      end
    end 
  end
end
