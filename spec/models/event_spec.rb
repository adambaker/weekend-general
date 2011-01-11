require 'spec_helper'

describe Event do
  before :each do
    @venue = Factory(:venue)
    @with_venue_attr = 
      {
        name: "a happy gathering",
        'date(1i)' => 2.days.from_now.year.to_s,
        'date(2i)' => 2.days.from_now.month.to_s,
        'date(3i)' => 2.days.from_now.day.to_s,
        time: '',
        price: '21.40',
        venue_id: @venue.id.to_s,
        address: '',
        city: '',
        links_attributes: [],
        description: ''
      }
    @with_address_attr = 
      { 
        name: 'war and famine',
        'date(1i)' => 2.weeks.from_now.year.to_s,
        'date(2i)' => 2.weeks.from_now.month.to_s,
        'date(3i)' => 2.weeks.from_now.day.to_s,
        time: '9pm', 
        price: '',
        venue_id: '',
        address: '1234 Evil hill',
        city: 'Chicago, Il',
        links_attributes: [
          {url: 'http://www.sadhole.co', text: 'Sad hole.'},
          {url: 'www.goldenforest.org', text: 'Desecration target'}
        ],
        description: venue_attr[:description]
      }
  end
  
  it 'should create a new instance with valid attributes.' do
    Event.create!(@with_venue_attr)
    Event.create!(@with_address_attr)
  end
  
  it "should use the venue's address when a venue is given." do
    event = Event.create @with_venue_attr
    event.address.should == @venue.address
    event.city.should == @venue.city
  end
  
  it 'should require a name.' do
    Event.new(@with_venue_attr.merge(name: '')).should_not be_valid
  end
  
  it 'should require an address.' do
    Event.new(@with_address_attr.merge(address: '')).should_not be_valid
  end
  
  it 'should require a city.' do
    Event.new(@with_address_attr.merge(city: '')).should_not be_valid
  end
  
  it 'should store the price as an integer in cents.' do
    event = Event.create(@with_venue_attr)
    event.price.should == (@with_venue_attr[:price].to_f*100).round
  end
  
  it 'should store a price that is not a number as nil.' do
    event = Event.create(@with_address_attr)
    event.price.should  be_nil
  end
  
  it 'should handle numbers with commas and dollars.' do
    event = Event.create(@with_venue_attr.merge(price: '$1,024'))
    event.price.should == 102400
  end
  
  it 'should have the appropriate date.' do
    event = Event.create(@with_venue_attr)
    event.date.year.should == 2.days.from_now.year
    event.date.month.should == 2.days.from_now.month
    event.date.day.should == 2.days.from_now.day
  end
  
  it 'should default to the local city.' do
    Event.new.city.should == WeekendGeneral::Local::city
  end
  
  it 'should contain a link for each links attribute.' do
    event = Event.create(@with_address_attr) 
    event.links.size.should == 2
  end
  
  it 'should reject invalid links.' do
    @with_venue_attr[:links_attributes] << {url: invalid_urls[0], text: ''}
    Event.new(@with_venue_attr).should_not be_valid
  end
  
end
