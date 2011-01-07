require 'spec_helper'

describe VenuesController do
  render_views
  
  before :each do
    @venue = Factory :venue
  end

  describe "GET index" do
    it "should be successful and have the right title." do
      get :index
      response.should be_success
      response.should have_selector :title, content: 'Venues'
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
    
    it "should have a link to the site's webpage." do
      get :index
      response.should have_selector(:a, href: @venue.url, content: 'website')
    end
    
    it "should display all the venues." do
      venues = [@venue]
      35.times do
        venues << Factory(:venue, name: Factory.next(:venue_name))
      end
      
      get :index
      venues.each do |venue|
        response.should have_selector :td, content: venue.name
      end 
    end
  end

  describe "GET show" do
    it "be successful and have the right title." do
      get :show, id: @venue
      response.should be_successful
      response.should have_selector :title, content: @venue.name
    end
    
    it "should have a link to the site's webpage." do
      get :show, id: @venue
      response.should have_selector(:a, href: @venue.url, content: 'website')
    end
    
    it "should have a sanitized, formatted description." do
      paragraphs = sanitized_description.split("\n")
      get :show, id: @venue
      response.should have_selector 'p a', href: 'www.ahappyplace.com',
                                            content: 'A Happy Place'
      response.should have_selector 'p em', content: 'hate'
      response.should have_selector 'p', content: 'Red Eye'
      response.should have_selector 'p', content: paragraphs[2]
      response.should_not have_selector 'p script'
    end
  end
  
  describe "when signed in" do
    before :each do
      test_sign_in Factory :user
      @new_attr = venue_attr.merge(name: 'A Sad Hole', url: 'http://sad.co')
      @invalid_attr = @new_attr.merge(name: '')
    end
    
    describe 'GET new' do  
      it "is successful and has the right title." do
        get :new
        response.should be_success
        response.should have_selector :title, content: 'venue intel'
      end
    
      it "should have the default city filled in." do
        get :new
        response.should have_selector 'input[type="text"]', value: 'Chicago, IL'
      end
    end
    
    describe 'GET edit' do
      it 'is successful and has the right title.' do
        get :edit, id: @venue
        response.should be_success
        response.should have_selector :title, content: 'Revise venue intel'
      end
      
      it "should have the venue's info in the form." do
        get :edit, id: @venue
        venue_attr.each do |key, value|
          unless key == :description
            response.should have_selector :input, value: value
          end
        end
        response.should contain venue_attr[:description].split("\n")[2]
      end
    end
    
    describe "POST create" do
      describe "with valid params" do
        it "redirects to the created venue with an appropriate flash" do
          post :create, venue: @new_attr
          response.should redirect_to venue_path assigns :venue
          flash[:success].should_not be_nil
          flash[:success].should == Themes::current_theme['venues']['new']
        end
        
        it "creates a new venue." do
          lambda do
            post :create, venue: @new_attr
          end.should change(Venue, :count).by 1
        end
      end

      describe "with invalid params" do
        it "re-renders the 'new' template" do
          post :create, venue: @invalid_attr
          response.should render_template("new")
        end
        
        it "should not add a new venue." do
          lambda do
            post :create, venue: @invalid_attr
          end.should_not change(Venue, :count)
        end
      end
    end

      
    describe "PUT update" do

      describe "with valid params" do
      
        it "redirects to the venue with an appropriate flash message." do
          put :update, id: @venue, venue: @new_attr
          response.should redirect_to @venue
          flash[:success].should_not be_nil
          flash[:success].should == Themes::current_theme['venues']['updated']
        end
        
        it "updates the requested venue" do
          put :update, id: @venue, venue: @new_attr
          @venue.reload
          @new_attr.each do |key, value|
            @venue.send(key).should == value
          end
        end
      end

      describe "with invalid params" do
        it "re-renders the 'edit' template" do
          put :update, id: @venue, venue: @invalid_attr
          response.should render_template("edit")
        end
        
        it 'should not change the venue.' do
          put :update, id: @venue, venue: @invalid_attr
          @venue.reload
          venue_attr.each do |key, value|
            @venue.send(key).should == value
          end
        end
      end
    end
    
    describe "DELETE destroy" do
      it "destroys the requested venue" do
        lambda do
          delete :destroy, id: @venue
        end.should change(Venue, :count).by -1
      end

      it "redirects to the venues list" do
        delete :destroy, id: @venue
        response.should redirect_to(venues_url)
        flash[:success].should_not be_nil
        flash[:success].should == Themes::current_theme['venues']['deleted']
      end
    end
  end
  
  describe "when not signed in." do
    it 'should redirect GET new to /auth/google on.' do
      get :new
      response.should redirect_to '/auth/google'
    end
    
    it 'should redirect GET edit to /auth/google.' do
      get :edit, id: @venue
      response.should redirect_to '/auth/google'
    end

    it 'should redirect PUT update without changing the venue.' do
      put :update, id: @venue, venue: @new_attr
      response.should redirect_to '/auth/google'
      @venue.reload
      venue_attr.each do |key, value|
        @venue.send(key).should == value
      end
    end
    
    it 'should redirect POST create to /auth/google.' do
      post :create, venue: @new_attr
      response.should redirect_to '/auth/google'
    end

    it 'should not let POST create make a new venue.' do
      lambda do
        post :create, venue: @new_attr
      end.should_not change(Venue, :count)
    end
    
    it 'should redirect DELETE destroy to /auth/google.' do
      delete :destroy, id: @venue
      response.should redirect_to '/auth/google'
    end
    
    it 'should not let DELETE destroy delete a venue.' do
      lambda do
        delete :destroy, id: @venue
      end.should_not change(Venue, :count)
    end
  end
end
