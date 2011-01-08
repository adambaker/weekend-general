require 'spec_helper'

describe "events/edit.html.haml" do
  before(:each) do
    @event = assign(:event, stub_model(Event,
      :name => "MyString",
      :price => 1,
      :venue => "",
      :address => "MyString",
      :city => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => event_path(@event), :method => "post" do
      assert_select "input#event_name", :name => "event[name]"
      assert_select "input#event_price", :name => "event[price]"
      assert_select "input#event_venue", :name => "event[venue]"
      assert_select "input#event_address", :name => "event[address]"
      assert_select "input#event_city", :name => "event[city]"
      assert_select "textarea#event_description", :name => "event[description]"
    end
  end
end
