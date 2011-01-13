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
          response.should have_selector(:a, href: event_path(event),
                                            content: event.name)
        end
      end
    end    
  end

  describe "GET show" do
    it 'should be successful.' do
      get :show, id: @event.id
      response.should be_success
    end
    
    it "should display the event's name and address." do
      get :show, id: @event.id
      response.should contain @event.name
      response.should contain @event.address
    end
    
    it "should display a list of links." do
      @event.links.create(url: 'foo.bar.com')
      @event.links.create(url: 'http://www.google.com', text: 'google')
      @event.links.create(url: 'another.example.com', text: 'example')
      
      get :show, id: @event.id
      @event.links.each do |link|
        response.should have_selector('li > a', href: link.url, 
                                                content: link.text)
      end
    end
    
    it "should have a sanitized description." do
      get :show, id: @event.id
      response.should_not have_selector 'td script'
      response.should have_selector :a, href: 'www.ahappyplace.com',
                                        content: 'A Happy Place'
      response.should have_selector :em, content: 'hate'
    end
    
    it "should show user rsvps." do
      users = [Factory(:user)]
      3.times {users << Factory(
        :user, email: Factory.next(:email), uid: Factory.next(:uid))}
      users[0].host @event
      users[1].attend @event
      users[2].attend @event
      users[3].maybe @event
      
      get :show, id: @event.id
      users.each {|u| response.should contain u.name}
      %w[Mastermind Operative Prospective].each {|w| response.should contain w}
    end
  end

  describe 'permission control' do
    it 'should require sign in for GET new' do
      get :new
      response.should redirect_to sign_in_path
    end
    
    it 'should require sign in for POST create' do
      post :create, event: {}
      response.should redirect_to sign_in_path
    end
    
    it 'should require sign in for GET edit' do
      get :edit, id: @event.id, event: {}
      response.should redirect_to sign_in_path
    end
    
    it 'should require sign in for PUT update' do
      put :update, id: @event.id, event: {}
      response.should redirect_to sign_in_path
    end
    
    it 'should require sign in for DELETE destroy' do
      delete :destroy, id: @event.id
      response.should redirect_to sign_in_path
    end
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
