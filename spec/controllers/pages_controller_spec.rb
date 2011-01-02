require 'spec_helper'

describe PagesController do
  render_views
  
  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end
    
    it 'should have "home" in the title' do
      get 'home'
      response.should have_selector(:title, content: 'home')
    end
    
    describe 'when signed in' do
      before(:each) do
        @user = Factory(:user)
        test_sign_in(@user)
        get 'home'
      end
      
      it 'should have a sign out link.' do
        response.should have_selector(:a, content: 'Sign out')
      end
      
      it "should have the current user's name in the header" do
        response.should have_selector(:div, content: @user.name)
      end
    end
    
    describe 'when not signed in' do
      before(:each) do
        get 'home'
      end
      
      it 'should have a sign in link.' do
        response.should have_selector(:a, content: 'Sign in')
      end
      
    end
  end
  
  describe 'GET "about"' do
    it "should be successful" do
      get 'about'
      response.should be_success
    end
    
    it 'should have "What is" in the title' do
      get 'about'
      response.should have_selector(:title, content: 'What is')
    end
  end
end
