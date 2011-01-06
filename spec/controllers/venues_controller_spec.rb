require 'spec_helper'

describe VenuesController do
  render_views
  
  before :each do
    @venue = Factory :venue
  end
    
  def mock_venue(stubs={})
    (@mock_venue ||= mock_model(Venue).as_null_object).tap do |venue|
      venue.stub(stubs) unless stubs.empty?
    end
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
  
  describe "GET new" do
    it "assigns a new venue as @venue" do
      Venue.stub(:new) { mock_venue }
      get :new
      assigns(:venue).should be(mock_venue)
    end
  end

  describe "GET edit" do
    it "assigns the requested venue as @venue" do
      Venue.stub(:find).with("37") { mock_venue }
      get :edit, :id => "37"
      assigns(:venue).should be(mock_venue)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created venue as @venue" do
        Venue.stub(:new).with({'these' => 'params'}) { mock_venue(:save => true) }
        post :create, :venue => {'these' => 'params'}
        assigns(:venue).should be(mock_venue)
      end

      it "redirects to the created venue" do
        Venue.stub(:new) { mock_venue(:save => true) }
        post :create, :venue => {}
        response.should redirect_to(venue_url(mock_venue))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved venue as @venue" do
        Venue.stub(:new).with({'these' => 'params'}) { mock_venue(:save => false) }
        post :create, :venue => {'these' => 'params'}
        assigns(:venue).should be(mock_venue)
      end

      it "re-renders the 'new' template" do
        Venue.stub(:new) { mock_venue(:save => false) }
        post :create, :venue => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested venue" do
        Venue.should_receive(:find).with("37") { mock_venue }
        mock_venue.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :venue => {'these' => 'params'}
      end

      it "assigns the requested venue as @venue" do
        Venue.stub(:find) { mock_venue(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:venue).should be(mock_venue)
      end

      it "redirects to the venue" do
        Venue.stub(:find) { mock_venue(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(venue_url(mock_venue))
      end
    end

    describe "with invalid params" do
      it "assigns the venue as @venue" do
        Venue.stub(:find) { mock_venue(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:venue).should be(mock_venue)
      end

      it "re-renders the 'edit' template" do
        Venue.stub(:find) { mock_venue(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested venue" do
      Venue.should_receive(:find).with("37") { mock_venue }
      mock_venue.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the venues list" do
      Venue.stub(:find) { mock_venue }
      delete :destroy, :id => "1"
      response.should redirect_to(venues_url)
    end
  end

end
