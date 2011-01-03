require 'spec_helper'

describe UsersController do
  render_views
  
  before(:each) do
    @user = Factory(:user)
    @user_attr = { provider: @user.provider,
                   uid:      @user.uid,
                   name:     @user.name,
                   email:    @user.email }
  end
  
  describe "GET index" do
    
    it "should be successful with 'Warrior muster' in the title." do
      get :index
      response.should be_success
      response.should have_selector :title, content: 'Warrior muster'
    end
    
    describe "with many users" do
      before(:each) do
        @users = [@user]
        35.times do
          @users << Factory(:user, uid:  Factory.next(:uid),
                                   email: Factory.next(:email))
        end
      end

      it "should have an element for each user." do
        get :index
        @users.each do |u|
          response.should have_selector :td, content: u.name
        end
      end
      
      it "should not have delete links." do
        get :index
        response.should_not have_selector :a, content: 'Destroy'
      end
      
      it "should not have emails when not signed in" do
        get :index
        @users.each do |u|
          response.should_not have_selector :td, content: u.email
        end
      end
      
      it "should have emails when signed in" do
        test_sign_in @user
        get :index
        @users.each do |u|
          response.should have_selector :td, content: u.email
        end
      end
    end
  end
  
  #just a reminder to go back and implement xml and json APIs
  describe "GET index.xml" do 
    it "should have an element for each user."
  end
  describe "GET index.json" do
    it "should have an element for each user."
  end

  describe "GET show" do
    it "should be successful w/ the user's name in the title." do
      get :show, id: @user
      response.should be_success
      response.should have_selector :title, content: @user.name
    end
  
    describe "when not signed in" do 
      it "should not have the user's email or edit link." do
        get :show, id: @user
        response.should_not contain @user.email
        response.should_not have_selector :a, href: "/users/#{@user.id}/edit" 
      end
    end

    describe "when signed in" do
      before :each do
        test_sign_in @user
      end
      
      it "should have the user's email." do
        get :show, id: @user
        response.should contain @user.email
      end
      
      it "should have an edit link if signed in as the same user" do
        get :show, id: @user
        response.should have_selector :a, href: "/users/#{@user.id}/edit"
      end
      
      it "should not have an edit link if signed in as a different user" do
        other_user = Factory(:user, 
          email: 'fake@phony.lie', uid: 'laughing-man')
        get :show, id: other_user
        response.should_not have_selector :a, href: "/users/#{@user.id}/edit"
      end
    end
  end

  describe "GET new" do
    it "should be successful w/ 'enlistment' in the title." do
      get :new
      response.should be_success
      response.should have_selector :title, content: 'enlistment' 
    end
          
    it "should redirect to root when signed in." do
      test_sign_in @user
      get :new
      response.should redirect_to root_path
    end
    
    it "should fill in the form with default values from params." do
      get :new, user: @user_attr
      response.should have_selector :input,type: 'hidden',value: @user.uid
      response.should have_selector :input,type: 'hidden',value: @user.provider
      response.should have_selector :input, type: 'text', value: @user.name
      response.should have_selector :input, type: 'text', value: @user.email
    end
  end

  describe "GET edit" do
    describe "when not signed in" do
      it "should redirect to /auth/google." do
        get :edit, id: @user
        response.should redirect_to '/auth/google'
      end 
    end
    
    describe "when signed in as the same user" do
      before :each do 
        test_sign_in @user
      end
      
      it "should be successful and have user's name in the title." do
        get :edit, id: @user
        response.should be_success
        response.should have_selector :title, content: @user.name
      end
      
      it "should have the user's information filled in." do
        get :edit, id: @user
        response.should have_selector :input,type: 'hidden',value: @user.uid
        response.should have_selector :input,type: 'hidden',value: @user.provider
        response.should have_selector :input, type: 'text', value: @user.name
        response.should have_selector :input, type: 'text', value: @user.email
      end
    end
    
    describe "when signed in as a different user" do
      before :each do
        other_user = Factory(:user, email: Factory.next(:email),
                                    uid:   Factory.next(:uid) )
        test_sign_in other_user
      end
      
      it "should redirect to the user's profile w/ a flash message." do
        get :edit, id: @user
        response.should redirect_to @user
        flash[:error].should =~ /can't edit another/i
      end
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "should create a new user."
      it "should redirect to the created user."
      it "should have an appropriate welcome message."
      it "should sign the user in."
    end

    describe "with invalid params" do
      it "should not create a new user."
      it "should re-render the 'new' template." 
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "should change the user's attributes."
      it "should have a flash message."
      it "should redirect to the user's show page."
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template."
      it "has the user's old name in the title."
    end

  end

  describe "DELETE destroy" do
    describe "when not signed in" do
      it "should not destroy the user."
      it "should redirect to the sign in page."
    end
    
    describe "as a different user" do
      it "should not destroy the user."
      it "should redirect to the user's show page."
    end
    
    describe "as the current user" do
      it "should destroy the user."
      it "should redirect to the home page."
      it "should display an appropriate flash message."
    end
    
    #admin features will be added later.
    describe "as an admin" do
      it "should destroy the user."
      it "should redirect to the users index page."
      it "should display an appropriate flash message."
      it "should send an email to the deleted user." 
    end
  end

end
