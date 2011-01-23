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
    
    it "should strip tags truncate description." do
      get :index
      response.should have_selector(:td, 
        content: stripped_description[0...47])
    end
    
    it "should have a link to the site's webpage." do
      get :index
      response.should have_selector(:a, href: @venue.url)
    end
    
    it "should display all the venues." do
      venues = [@venue]
      35.times do
        venues << Factory(:venue, name: Factory.next(:name))
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
      response.should have_selector(:a, href: @venue.url)
    end
    
    it "should have a sanitized, formatted description." do
      get :show, id: @venue
      test_sanitized_description
    end
    
    it "should not have an edit link." do
      get :show, id: @venue
      response.should_not have_selector(:a, href: edit_venue_path(@venue))
    end
    
    it "should list its events." do
      events = [Factory(:event, venue: @venue)]
      3.times{events << Factory(:event, name: Factory.next(:name),
        venue: @venue)}
      get :show, id: @venue
      events.each do |e|
        response.should have_selector :a, href: event_path(e), 
          content: e.name
      end
    end
    
    describe "when signed in" do
      before :each do
        @user = test_sign_in(Factory :user)
        set_rank @user, 1
      end
      
      [2, 3, 4].each do |i|
        it "as a rank #{i} user should have an edit link." do
          set_rank @user, i
          get :show, id: @venue
          response.should have_selector(:a, href: edit_venue_path(@venue))
        end
      end
            
      it "should not have an edit link for rank 1 users." do
        get :show, id: @venue
        response.should_not have_selector(:a, href: edit_venue_path(@venue))
      end
      
      it "should have the edit link if the rank 1 user created the venue." do
        @venue.created_by = @user.id
        @venue.save
        get :show, id: @venue
        response.should have_selector(:a, href: edit_venue_path(@venue))
      end
    end
  end
  
  describe "when signed in" do
    before :each do
      @user = test_sign_in Factory :user
      set_rank @user, 2
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
        response.should have_selector 'input[type="text"]', 
          value: Settings::city
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
      
      it "should have a delete button." do
        get :edit, id: @venue
        response.should have_selector :a, content: 'Remove this venue'
      end
      
      it "should not allow edit if the user is rank 1." do
        set_rank @user, 1
        get :edit, id: @venue
        test_rank_flash
        response.should redirect_to @venue
      end
      
      it "should allow rank 1 user edit if user created the venue." do
        set_rank @user, 1
        @venue.created_by = @user.id
        @venue.save
        get :edit, id: @venue
        response.should be_success
      end
      
      [3, 4].each do |i|
        it "should allow edit if the user's rank is #{i}." do
          set_rank @user, i
          get :edit, id: @venue
          response.should be_success
        end
      end
    end
    
    describe "POST create" do
      describe "with valid params" do
        it "redirects to the created venue with an appropriate flash" do
          post :create, venue: @new_attr
          response.should redirect_to venue_path assigns :venue
          test_flash :success, 'venues', 'new'
        end
        
        it "creates a new venue." do
          lambda do
            post :create, venue: @new_attr
          end.should change(Venue, :count).by 1
        end
        
        it "should assign the venue the right created_by id" do
          post :create, venue: @new_attr
          Venue.find_by_name(@new_attr[:name]).created_by.should == @user.id
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
          test_flash :success, 'venues', 'updated'
        end
        
        it "updates the requested venue" do
          put :update, id: @venue, venue: @new_attr
          @venue.reload
          test_attrs_equal @venue, @new_attr
        end
        
        it "should not allow update if the user is rank 1." do
          set_rank @user, 1
          put :update, id: @venue, venue: @new_attr
          test_rank_flash
          response.should redirect_to @venue
          test_attrs_equal(@venue, venue_attr)
        end
        
        it "should allow rank 1 user update if user created the venue." do
          set_rank @user, 1
          @venue.created_by = @user.id
          @venue.save
          put :update, id: @venue, venue: @new_attr
          test_attrs_equal @venue, @new_attr
        end
        
        [3, 4].each do |i|
          it "should allow update if the user's rank is #{i}." do
            set_rank @user, i
            put :update, id: @venue, venue: @new_attr
            test_attrs_equal(@venue, @new_attr)
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
          test_attrs_equal(@venue, venue_attr)
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
        test_flash :success, 'venues', 'deleted'
      end
      
      it "should not allow destroy if the user is rank 1." do
        set_rank @user, 1
        delete :destroy, id: @venue
        test_rank_flash
        response.should redirect_to @venue
      end
      
      it "should allow rank 1 user destroy if user created the venue." do
        set_rank @user, 1
        @venue.created_by = @user.id
        @venue.save
        lambda do
          delete :destroy, id: @venue
        end.should change(Venue, :count).by -1
      end
      
      [3, 4].each do |i|
        it "should allow destroy if the user's rank is #{i}." do
          set_rank @user, i
          lambda do
            delete :destroy, id: @venue
          end.should change(Venue, :count).by -1
        end
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
