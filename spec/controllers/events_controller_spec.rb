require 'spec_helper'

describe EventsController do
  render_views
  
  before :each do
    @event = Factory(:event)
  end
  
  describe "GET index" do
    it "should be successful." do
      get :index
      response.should be_success
    end
    
    it "should not have delete links." do
      get :index
      response.should_not have_selector :a, content: 'destroy'
    end
    
    it "should strip tags truncate description to 50 characters." do
      get :index
      response.should have_selector(:td, 
        content: stripped_description[0...47]+'...')
    end
    
    describe 'with many events' do
      before :each do 
        @events = [@event]
        35.times { @events << Factory(:event, name: Factory.next(:name)) }
      end
       
      it "should have an entry for each event" do
        get :index
        @events.each do |event|
          response.should have_selector :a, href: event_path(event),
                                            content: event.name
        end
      end
    end    
  end

  describe "GET show" do

  end

  describe "GET new" do

  end

  describe "GET edit" do

  end

  describe "POST create" do

    describe "with valid params" do

    end

    describe "with invalid params" do

    end

  end

  describe "PUT update" do

    describe "with valid params" do

    end

    describe "with invalid params" do

    end

  end

  describe "DELETE destroy" do

  end

end
