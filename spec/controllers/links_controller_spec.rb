require 'spec_helper'

describe LinksController do
  before :each do
    @event = Factory :event
    @valid = {url: 'http://foo.co', text: 'foobar'}
    @invalid = {url: 'never'}
    @attr = {url: 'http://space.edu'}
    @link = @event.links.create @attr
  end
  
  describe 'permission controll' do

    it 'should require signin for create.' do
      lambda do
        post :create, event_id: @event.id, link: @valid
        response.should redirect_to sign_in_path
      end.should_not change(Link, :count)
    end
    
    it 'should require signin for update.' do
      lambda do
        put :update, event_id: @event.id, id: @link.id, link: @valid
        response.should redirect_to sign_in_path
      end.should_not change(@link, :url)
    end
    
    it 'should require signin for destroy.'do 
      lambda do
        delete :destroy, event_id: @event.id, id: @link.id
        response.should redirect_to sign_in_path
      end.should_not change(Link, :count)
    end
  end
  
  describe 'when signed in' do
    before :each do
      test_sign_in Factory(:user)
    end
    
    describe 'POST create' do
      describe 'with valid params.' do
        it 'should redirect to the event edit.' do
          post :create, event_id: @event.id, link: @valid
          response.should redirect_to edit_event_path @event
        end
        
        it 'should create a new link.' do
          lambda { post :create, event_id: @event.id, link: @valid }
            .should change(Link, :count).by(1)
        end
      end
      
      describe 'with invalid params' do
        it 'should redirect to the event edit.' do
          post :create, event_id: @event.id, link: @invalid
          response.should redirect_to edit_event_path(@event)
        end
        
        it 'should not create a new link.' do
          lambda {post :create, event_id: @event.id, link: @invalid}
            .should_not change(Link, :count)
        end
      end
    end
    
    describe 'PUT update' do
      
      describe 'with valid params.' do
        it 'should redirect to the event edit.' do
          put :update, event_id: @event.id, link: @valid, id: @link.id
          response.should redirect_to edit_event_path @event
        end
        
        it 'should update link.' do
          put :update, event_id: @event.id, link: @valid, id: @link.id
          @link.reload
          @link.url.should == @valid[:url]
        end
      end
      
      describe 'with invalid params' do
        it 'should redirect to the event edit.' do
          put :update, event_id: @event.id, link: @invalid, id: @link.id
          response.should redirect_to edit_event_path @event
        end
        
        it 'should not change link.' do
          put :update, event_id: @event.id, link: @invalid, id: @link.id
          @link.reload
          @link.url.should == @attr[:url]
        end
      end
    end
    
    describe 'DELETE destroy' do      
      it 'should redirect to the event edit.' do 
        delete :destroy, event_id: @event.id, id: @link.id
        response.should redirect_to edit_event_path @event
      end
      
      it 'should delete the link.' do
        lambda {delete :destroy, event_id: @event.id, id: @link.id}
          .should change(Link, :count).by(-1)
      end
    end
  end
end
