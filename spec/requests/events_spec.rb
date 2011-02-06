require 'spec_helper'

describe "Events" do
  before :each do
    @attr = 
      {
        name: 'Terrible deep', 
        email: 'never@publish.me', 
        provider: 'google',
        uid: 'alwaysandfornever.fool',
        description: 'I never want to die but always fear I will.'
      }
    integration_new_user @attr
    @venue = Factory(:venue)
  end
  
  describe "creating new events" do
    describe 'failure' do
      it "should not make a new event." do
        -> do
          visit events_path
          click_link 'Post a new event'
          fill_in "Name",    with: ""
          fill_in "Address", with: ''
          click_button
          response.should render_template('events/new')
          response.should have_selector("div#error_explanation")
        end.should_not change(Event, :count)
      end
    end
    
    describe 'success' do
      it "should make a new event." do
        lambda do
          visit new_event_path
          fill_in "Name", with: "Hilarious time"
          fill_in "Address", with: @venue.address
          fill_in "Description", with: "This is going to be funny as shit."
          click_button
          response.should have_selector("div.flash div.success")
          response.should render_template('events/show')
        end.should change(Event, :count).by(1)
      end
    end
  end
  
  describe 'search and sort' do
    before :each do 
      @tomorrow = Factory(:event, date: Time.zone.today + 1.day)
      @today = Factory(:event, name: Factory.next(:name), date: Time.zone.today)
      @past = Factory(:event, name: Factory.next(:name), date: 2.days.ago)
      @future = Factory(:event, name: Factory.next(:name), 
        date: 75.days.from_now)
    end
    
    it "should filter the events." do
      visit events_path
      contains_names [@tomorrow, @today, @future]
      contains_names [@past], false
      click_button "This month's events"
      contains_names [@tomorrow, @today]
      contains_names [@past, @future], false
      click_button "Past events"
      contains_names [@past]
      contains_names [@tomorrow, @today, @future], false
      click_button "This week's events"
      contains_names [@tomorrow, @today]
      contains_names [@past, @future], false
      click_button "Today's events"
      contains_names [@today]
      contains_names [@tomorrow, @past, @future], false
      click_button "All Upcoming Events"
      contains_names [@tomorrow, @today, @future]
      contains_names [@past], false
    end
    
    it "should pass the right search defaults when filling in a search." do
      visit root_path
      fill_in 'small_search_text', with: ''
      submit_form 'small_search_form'
      #should default to any price, all future events, all events, venues,
      #and users
      response.should contain @attr[:description]
      contains_names [@tomorrow, @today, @future, @venue]
      contains_names [@past], false
      
      response.should have_selector :input, type: 'checkbox', name: 'user',
        checked: 'checked'
      response.should have_selector :input, type: 'checkbox', name: 'event',
        checked: 'checked'
      response.should have_selector :input, type: 'checkbox', name: 'venue',
        checked: 'checked'
      response.should have_selector :input, type: 'radio', name: 'when', 
        value: 'future', checked: 'checked'
      response.should have_selector :input, type: 'radio', name: 'price', 
        value: 'any', checked: 'checked'
    end
  end
end
