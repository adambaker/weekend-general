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
    
    it "should have a link to the venue." do
      venue = Factory(:venue)
      @event.venue = venue
      @event.save
      get :index
      response.should have_selector :a, href: venue_path(venue), 
        content: venue.name
    end
    
    it "should strip tags and truncate description to 50 characters." do
      get :index
      response.should have_selector(:td, 
        content: stripped_description[0...47]+'...')
    end
    
    it "should not display past events in the." do
      other_event = Factory(:event, name: Factory.next(:name), date: 1.day.ago)
      get :index
      response.should_not contain other_event.name
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
    
    it "should have a link to the venue page." do
      venue = Factory(:venue)
      @event.venue = venue
      @event.save
      get :show, id: @event.id
      response.should have_selector :a, href: venue_path(venue),
        content: venue.name
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
    
    describe "rsvp display." do
      before :each do
        @users = [Factory(:user)]
        3.times {@users << Factory(
          :user, email: Factory.next(:email), uid: Factory.next(:uid))}
        @users[0].host @event
        @users[1].attend @event
        @users[2].attend @event
        @users[3].maybe @event
      end
      
      it "should show user rsvps when signed in." do      
        test_sign_in @users[0]
        get :show, id: @event.id
        @users.each {|u| response.should contain u.name}
        %w[Mastermind Operative Prospective].each {|w| response.should contain w}
      end
      
      it "should not show user rsvps when not signed in." do
        get :show, id: @event.id
        @users.each {|u| response.should_not contain u.name}
        %w[Mastermind Operative Prospective].each do |w| 
          response.should_not contain w
        end
      end
    end
    
    describe 'with a signed in user.' do
      before :each do
        @user = test_sign_in Factory :user
        set_rank @user, 1
      end
      
      it 'should have rsvp buttons.' do
        get :show, id: @event.id
        response.should have_selector 'input',
          value: 'Maybe...', type: 'submit'
        response.should have_selector 'input',
          value: "I'm hosting/organizing"
        response.should have_selector 'input',
          value: "I'm going", type: 'submit'
      end
      
      it "should change rsvp buttons if you've already rsvp'd." do
        @user.attend @event
        get :show, id: @event
        response.should have_selector 'input',
          value: 'Maybe...', type: 'submit'
        response.should have_selector 'input',
          value: "I'm hosting/organizing"
        response.should have_selector 'input',
          value: "I won't be there", type: 'submit'
      end
      
      it "should not have an edit button." do
        get :show, id: @event
        response.should_not have_selector :a, href: edit_event_path(@event)
      end
      
      it "should have the edit button if the user created the event." do
        set_creator @event, @user
        get :show, id: @event
        response.should have_selector :a, href: edit_event_path(@event)
      end
      
      [2, 3, 4].each do |i|
        it "should have an edit button for rank #{i}." do
          set_rank @user, i
          get :show, id: @event
          response.should have_selector :a, href: edit_event_path(@event)
        end
      end
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
  
  describe 'when signed in' do
    before :each do
      @user = test_sign_in Factory(:user)
      set_rank @user, 2
    end
    
    describe "GET new" do
      it 'should be successful.' do
        get :new
        response.should be_success
      end
      
      it "should have the default city filled in." do
        get :new
        response.should have_selector 'input[type="text"]', 
          value: Settings::city
      end
      
      it 'should have name and address text fields.' do
        get :new
        %w[name address price time].each do |attr|
          response.should have_selector :input, 
            name: "event[#{attr}]", type: 'text'
        end
      end
      
      it 'should have a Venue selector.' do
        venues = [Factory(:venue)]
        4.times {venues << Factory(:venue, name: Factory.next(:name))}
        get :new
        response.should have_selector :select, name: 'event[venue_id]'
        response.should have_selector :option, value: 'no_venue',
          content: '--'
        venues.each do |venue|
          response.should have_selector :option, value: venue.id.to_s,
            content: venue.name
        end
      end
      
      it 'should have an empty set of link fields.' do
        get :new
        response.should have_selector :input, type: 'text', 
          name: 'event[links_attributes][0][url]'
      end
    end

    describe "GET edit" do
      it 'should be successful.' do
        get :edit, id: @event.id
        response.should be_success
      end
      
      it 'should have all the links with an extra blank link field.' do
        @event.links.create({url: 'http://terrible.co'})
        @event.links.create({url: 'http://gorby.ru'})
        get :edit, id: @event.id
        response.should have_selector :input, type: 'text', 
          name: 'event[links_attributes][0][url]',
          value: 'http://terrible.co'
        response.should have_selector :input, type: 'text', 
          name: 'event[links_attributes][1][url]',
          value: 'http://gorby.ru'
      end
      
      it "should have a delete button." do
        get :edit, id: @event
        response.should have_selector :input, name: '_method', value: 'delete'
      end
      
      it "should redirect rank 1 users." do
        set_rank @user, 1
        get :edit, id: @event
        response.should redirect_to @event
        test_rank_flash
      end
      
      it "should succeed for rank 1 user who created the event." do
        set_rank @user, 1
        set_creator @event, @user
        get :edit, id: @event
        response.should be_success
      end
      
      [3, 4].each do |i|
        it "should succeed for rank #{i} users." do
          set_rank @user, i
          get :edit, id: @event
          response.should be_success
        end
      end
    end
    
    describe 'create and update' do
      before :each do
        @valid_attr = valid_event_attr
        @invalid_attr = valid_event_attr.merge({name: ''})
      end
    
    
      describe "POST create" do
        describe "with valid params" do
          it 'should redirect to the new event.' do
            post :create, event: @valid_attr
            response.should redirect_to event_path assigns :event
            test_flash :success, 'events', 'new'
          end
          
          it 'should create a new event.' do
            lambda {post :create, event: @valid_attr}
              .should change(Event, :count).by 1
          end
          
          it 'should assign the right id to created_by.' do
            post :create, event: @valid_attr
            Event.find_by_name(@valid_attr[:name]).created_by.should == @user.id
          end
        end

        describe "with invalid params" do
          it "should render the new template." do
            post :create, event: @invalid_attr
            response.should render_template 'new'
          end
          
          it "should not create a new event." do
            lambda {post :create, event: @invalid_attr}
              .should_not change(Event, :count)
          end
        end
      end

      describe "PUT update" do

        describe "with valid params" do
          it 'should redirect to the event with an appropriate flash.' do
            put :update, id: @event.id, event: @valid_attr
            response.should redirect_to @event
            test_flash :success, 'events', 'updated'
          end
          
          it 'should update the event.' do
            put :update, id: @event.id, event: @valid_attr
            @event.reload
            @event.name.should == @valid_attr[:name]
            @event.address.should == @valid_attr[:address]
          end
          
          it "should redirect rank 1 users without updating." do
            name, address = @event.name, @event.address
            set_rank @user, 1
            put :update, id: @event, event: @valid_attr
            response.should redirect_to @event
            test_rank_flash
            @event.name.should == name
            @event.address.should == address
          end
          
          it "should succeed for rank 1 user who created the event." do
            set_rank @user, 1
            set_creator @event, @user
            put :update, id: @event, event: @valid_attr
            @event.reload
            @event.name.should == @valid_attr[:name]
            @event.address.should == @valid_attr[:address]
          end
          
          [3, 4].each do |i|
            it "should succeed for rank #{i} users." do
              set_rank @user, i
              put :update, id: @event, event: @valid_attr
              @event.reload
              @event.name.should == @valid_attr[:name]
              @event.address.should == @valid_attr[:address]
            end
          end
        end

        describe "with invalid params" do
          it "should render the edit template." do
            put :update, id: @event.id, event: @invalid_attr
            response.should render_template 'edit'
          end
          
          it "should not change the event." do
            name, address = @event.name, @event.address
            put :update, id: @event.id, event: @invalid_attr
            @event.reload
            @event.name.should == name
            @event.address.should == address
          end
        end
      end
    end
    
    describe "DELETE destroy" do
      it "should redirect to the events list with a flash." do
        delete :destroy, id: @event.id
        response.should redirect_to events_path
        test_flash :success, 'events', 'deleted'
      end
      
      it "should delete the event." do
        lambda {delete :destroy, id: @event.id}.should change(Event, :count)
          .by -1
      end
      
      it "should redirect rank 1 users without deleting the event." do
        set_rank @user, 1
        lambda do
          delete :destroy, id: @event
          response.should redirect_to @event
          test_rank_flash
        end.should_not change(Event, :count)
      end
      
      it "should succeed for rank 1 user who created the event." do
        set_rank @user, 1
        set_creator @event, @user
        lambda{delete :destroy, id: @event}.should change(Event, :count).by -1
      end
      
      [3, 4].each do |i|
        it "should succeed for rank #{i} users." do
          set_rank @user, i
          lambda{delete :destroy, id: @event}.should change(Event, :count).by -1
        end
      end
    end
  end
end
