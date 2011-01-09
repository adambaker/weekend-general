require 'spec_helper'

describe UsersController do
  render_views
  
  def test_flash(type, message)
    flash[type].should_not be_nil
    flash[type].should == Themes::current_theme['users'][message]
  end
  
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
      test_flash :error, 'already_signed_in'
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
        test_flash :error, 'edit_not_you'
      end
    end
  end

  describe "POST create" do

    describe "with valid params" do
      before :each do
        @attr = @user_attr.merge email: 'fake@phony.lie', uid: 'new_uid'
      end
      
      it "should create a new user." do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end
      
      it "should redirect to the created user with a welcome message." do
        post :create, user: @attr
        response.should redirect_to User.find_by_email @attr[:email]
        test_flash :success, 'signed_up'
      end
      
      it "should sign the user in." do
        post :create, user: @attr
        controller.current_user.email.should == @attr[:email]
      end
      
      describe "with a user signed in" do
        before :each do
          test_sign_in @user
        end
        
        it "should not create a new user." do
          lambda do
            post :create, :user => @attr
          end.should_not change(User, :count)
        end
        
        it "should redirect to root with an appropriate message." do
          post :create, user: @attr
          response.should redirect_to root_path
          test_flash :error, 'already_signed_in'
        end 
      end
    end

    describe "with invalid params" do
      it "should not create a new user." do
        lambda do
          post :create, :user => @user_attr
        end.should_not change(User, :count)
      end
      
      it "should re-render the 'new' template." do
        post :create, user: @user_attr
        response.should render_template 'new'
      end
    end  
  end

  describe "PUT update" do
    describe 'when signed in as the updated user' do
      before :each do
        test_sign_in @user
      end
      
      describe "with valid params" do
        before :each do
          @new_attr = @user_attr.merge email: 'fake@phony.lie'
        end
        
        it "should change the user's attributes." do
          put :update, id: @user, user: @new_attr
          @user.reload
          @new_attr.each do |k, v|
            @user.send(k).should == v
          end
        end
        
        it "should redirect to the user's show page w/ a flash message." do
          put :update, id: @user, user: @new_attr
          response.should redirect_to @user
          test_flash :success, 'updated'
        end
      end

      describe "with invalid params" do
        before :each do
          @new_attr = @user_attr.merge email: 'fake'
        end
        
        it "re-renders the 'edit' template." do
          put :update, id: @user, user: @new_attr
          response.should render_template 'edit'
        end
        
        it "does not change the user's attributes." do
          put :update, id: @user, user: @new_attr
          @user.reload
          @user_attr.each do |k, v|
            @user.send(k).should == v
          end
        end
      end
      
      describe "when changing uid and provider" do
        it "should reject a change of uid" do
          put :update, id: @user, user: @user_attr.merge(uid: 'evil')
          response.should be_redirect
          test_flash :error, 'edit_uid'
          @user.reload
          @user.uid.should == @user_attr[:uid]
        end
        
        it "should reject a change of provider" do
          put :update, id: @user, user: @user_attr.merge(provider: 'evil')
          response.should be_redirect
          test_flash :error, 'edit_uid'
          @user.reload
          @user.uid.should == @user_attr[:uid]
        end
      end
    end
    
    describe 'when signed in as a different user' do
      before :each do
        test_sign_in Factory(:user, email: 'fake@phony.lie', uid: 'new_uid')
        @new_attr = @user_attr.merge email: 'even-more-fake@phony.lie'
      end
      
      it "does not change the user's attributes." do
        put :update, id: @user, user: @new_attr
        @user.reload
        @user_attr.each do |k, v|
          @user.send(k).should == v
        end
      end
      
      it "redirects to the user's show page with a flash message." do
        put :update, id: @user, user: @new_attr
        response.should redirect_to @user
        test_flash :error, 'edit_not_you'
      end
    end
    
    describe 'when not signed in' do
      before :each do
        @new_attr = @user_attr.merge email: 'fake@phony.lie'
      end
      
      it "does not change the user's attributes." do
        put :update, id: @user, user: @new_attr
        @user.reload
        @user_attr.each do |k, v|
          @user.send(k).should == v
        end
      end
      
      it "redirects to the user's show page with a flash message." do
        put :update, id: @user, user: @new_attr
        response.should redirect_to '/auth/google'
      end
    end
  end

  describe "DELETE destroy" do
    describe "when not signed in" do
      it "should not destroy the user." do
        lambda do
          delete :destroy, id: @user
        end.should_not change(User, :count)
      end
      
      it "should redirect to /auth/google." do
        delete :destroy, id: @user
        response.should redirect_to '/auth/google'
      end
    end
    
    describe "as a different user" do
      before :each do
        test_sign_in Factory(:user, email: 'fake@phony.lie', uid: 'new_uid')
      end
      
      it "should not destroy the user." do
        lambda do
          delete :destroy, id: @user
        end.should_not change(User, :count)
      end
      
      it "should redirect to the user's show page with a flash message." do
        delete :destroy, id: @user
        response.should redirect_to @user
        test_flash :error, 'destroy_not_you'
      end
    end
    
    describe "as the current user" do
      before :each do
        test_sign_in @user
      end
      
      it "should destroy the user." do
        lambda do
          delete :destroy, id: @user
        end.should change(User, :count).by -1
      end
      
      it "should redirect to the home page w/ a flash message." do
        delete :destroy, id: @user
        response.should redirect_to root_path
        test_flash :success, 'destroyed'
      end
      
      it "should sign the user out." do
        delete :destroy, id: @user
        controller.current_user.should be_nil
      end
    end
    
    #admin features will be added later.
    describe "as an admin" do
      before :each do
        @admin = Factory(:user, email: WeekendGeneral::Local::admins[0], 
            uid: Factory.next(:uid) )
        test_sign_in @admin
      end
      
      it "should destroy the user." do
        lambda do
          delete :destroy, id: @user
        end.should change(User, :count).by -1
      end
      
      it "should redirect to the users index page with an appropriate flash." do
        delete :destroy, id: @user
        response.should redirect_to users_path
        test_flash :success, 'admin_destroy'
      end
      
      it "should send an email to the deleted user." 
    end
  end

end
