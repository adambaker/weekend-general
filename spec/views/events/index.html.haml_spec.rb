require 'spec_helper'

describe "events/index.html.haml" do
  before(:each) do
    assign(:events, [
      stub_model(Event,
        :name => "Name",
        :price => 1,
        :venue => "",
        :address => "Address",
        :city => "City",
        :description => "MyText"
      ),
      stub_model(Event,
        :name => "Name",
        :price => 1,
        :venue => "",
        :address => "Address",
        :city => "City",
        :description => "MyText"
      )
    ])
  end

  it "renders a list of events" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Address".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "City".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
