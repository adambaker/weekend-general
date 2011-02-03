require 'spec_helper'

describe Venue do
  before :each do 
    @attr = venue_attr
  end
  
  it "should create a new instance with valid parameters." do
    Venue.create! @attr
  end
  
  it "should require a name." do
    venue = Venue.new @attr.merge(name: '')
    venue.should_not be_valid
  end
  
  it 'should require an address.' do
    venue = Venue.new @attr.merge(address: '')
    venue.should_not be_valid
  end
  
  valid_urls.each do |url|
    it "should accept #{url} as a valid URL." do
      venue = Venue.new @attr.merge(url: url)
      venue.should be_valid
    end
  end
  
  invalid_urls.each do |url|
    it "should reject #{url} as an invalid URL." do
      venue = Venue.new @attr.merge(url: url)
      venue.should_not be_valid
    end
  end
  
  it "should require a unique name given an address/city." do
    Venue.create @attr
    Venue.new(@attr).should_not be_valid
    Venue.new(@attr.merge address: '1234 sad road').should be_valid
    Venue.new(@attr.merge city: 'Evanston').should be_valid
  end
  
  it "should require a city." do
    Venue.new(@attr.merge city: '').should_not be_valid
  end
  
  it "should prefix url with http:// if no protocol is not present." do
    venue = Venue.create!(@attr.merge(url: 'www.ahappyplace.com'))
    venue.url.should == @attr[:url]
  end
  
  it "should not prefix url with a protocol if one is present." do
    venue = Venue.create!(@attr)
    venue.url.should == @attr[:url]
  end
  
  it "should not prefix a blank url." do
    venue = Venue.create!(@attr.merge(url: ''))
    venue.url.should == ''
  end
  
  it "should track its events." do
    venue = Venue.create(@attr)
    events = [Factory(:event, venue_id: venue.id)]
    5.times { events << Factory(:event,
      venue_id: venue.id, name: Factory.next(:name)) }
    venue.events.should == events
  end
  
  it "should have a created_by attribute." do
    Venue.create(@attr).should respond_to :created_by
  end
  
  describe "search" do
    before :each do
      @venue = Factory :venue
      @poop = Factory(:venue, name: 'poopyface')
      @nincompoop = Factory(:venue, name: 'Nincompoop Hangout')
      @cellar = Factory(:venue, name: Factory.next(:name),
        description: 'The best part is the demon in the cellar!')
    end
    
    it "should not contain @event or @cellar." do
      Venue.search('poop').should_not include(@venue)
      Venue.search('poop').should_not include(@cellar)
    end
    
    it "should contain @poop and @nincompoop." do
      poop = Venue.search('poop')
      poop.should include(@poop)
      poop.should include(@nincompoop)
      poop.size.should == 2
    end
    
    it "should contain @cellar when searching 'cellar'" do
      cellar = Venue.search('cellar')
      cellar.should include(@cellar)
      cellar.size.should == 1
    end
  end
end
