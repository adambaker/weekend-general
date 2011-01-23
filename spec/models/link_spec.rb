require 'spec_helper'

describe Link do
  before :each do
    @event = Factory(:event)
    @attr = {url: 'http://www.foo.com', text: 'Foo'}
  end
  
  it "should accept valid attributes" do
    @event.links.create!(@attr)
  end
  
  invalid_urls.each do |url|
    it "should reject #{url} as an invalid URL." do
      @event.links.build(url: url, text: 'foo').should_not be_valid
    end
  end
  
  valid_urls.each do |url|
    it "should accept #{url} as a valid URL." do
      @event.links.build(url: url, text: 'foo').should be_valid
    end
  end
  
  it "should prefix url with http:// if no protocol is not present." do
    link = @event.links.create!(@attr.merge(url: 'www.foo.com'))
    link.url.should == @attr[:url]
  end
  
  it "should not prefix url with a protocol if one is present." do
    link = @event.links.create!(@attr)
    link.url.should == @attr[:url]
  end
  
  it "should use the url as the text if no text is given." do
    link = @event.links.create! @attr.merge(text: '')
    link.text.should == @attr[:url]
  end
end
