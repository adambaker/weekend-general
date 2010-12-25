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
  end

end
