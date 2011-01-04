require "spec_helper"

describe VenuesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/venues" }.should route_to(:controller => "venues", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/venues/new" }.should route_to(:controller => "venues", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/venues/1" }.should route_to(:controller => "venues", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/venues/1/edit" }.should route_to(:controller => "venues", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/venues" }.should route_to(:controller => "venues", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/venues/1" }.should route_to(:controller => "venues", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/venues/1" }.should route_to(:controller => "venues", :action => "destroy", :id => "1")
    end

  end
end
