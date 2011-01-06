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
  
  it "should accept valid URLs." do
    valid_urls = [ 'http://foo.bar.com', 'www.go-here-now.il', 'find.us',
      'punch.com/users/1/get?foo=1&bar=2', 'http://go.co?goo=foo',
      'am.de/pan_da+all/man?squill=seminal', 'foo.co?e=foo%40goo.co', '' ]
    valid_urls.each do |url|
      venue = Venue.new @attr.merge(url: url)
      venue.should be_valid
    end
  end
  
  it "should reject invalid URLs." do
    invalid_urls = ['foo', 'foo?a=12', 'game/tell.us', '1934://punt.me',
      'sq\\id://foo.bar', 'www.foo.bar.com/seven-tell()/go' ]
    invalid_urls.each do |url|
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
    venue = Venue.create!(@attr)
    venue.url.should == 'http://'+@attr[:url]
  end
  
  it "should not prefix url with a protocol if one is present." do
    venue = Venue.create!(@attr.merge(url: 'http://ahappyplace.com'))
    venue.url.should == 'http://ahappyplace.com'
  end
  
  it "should not prefix a blank url." do
    venue = Venue.create!(@attr.merge(url: ''))
    venue.url.should == ''
  end
end
