require 'spec_helper'

describe SessionsController do
  
  describe 'POST "create"' do
    before(:each) do
      auth_request_attr = {'provider'=>'google', 'uid'=>'foobar',
          'user_info'=>{'name'=>"user", 'email'=>"user@example.com"}}
      controller.request.env["omniauth.auth"] = auth_request_attr
    end
    
    describe 'with a user signed in' do
      before :each do
        @user = Factory(:user, email: Factory.next(:email),
                               uid: Factory.next(:uid) )
        test_sign_in @user
      end
      
      it "should redirect to the user's show page." do
        post :create
        response.should redirect_to @user
      end
      
      it "should have an appropriate flash message." do
        post :create
        flash[:notice].should =~ /I already know you're here, warrior./i
      end
    end
    
    describe 'with a new user' do
      it "should redirect to new user with appropriate parameters." do
        post :create
        response.should redirect_to '/users/new?user[email]=user%40example.com&user[name]=user&user[provider]=google&user[uid]=foobar'
      end
    end
    
    describe 'with an existing user' do
      before :each do
        @user = Factory(:user)
      end
      
      it "should sign the user in." do
        post :create
        controller.current_user.should == @user
      end
      
      it "should redirect the user to root." do
        post :create
        response.should redirect_to root_path
      end
      
      it "should have an appropriate flash message." do
        post :create
        flash[:notice].should =~ /fall in/i
      end
    end
  end
  
  describe 'DELETE destroy' do 
    describe 'with a user signed in' do
      before :each do
        @user = Factory(:user)
        test_sign_in @user
      end
      
      it "should sign out the user." do
        delete :destroy
        controller.current_user.should be_nil
      end
      
      it "should redirect to root." do
        delete :destroy
        response.should redirect_to root_path
      end
      
      it "should have an appropriate flash message." do
        delete :destroy
        flash[:notice].should =~ /dismissed/i
      end
    end
    
    describe 'with no user signed in' do
      it "should redirect to root." do
        delete :destroy
        response.should redirect_to root_path
      end
      
      it "should have an error message." do
        delete :destroy
        flash[:error].should =~ /sound off .* dismissed/i
      end
    end
  end
end
