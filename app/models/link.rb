class Link < ActiveRecord::Base
  URL_REGEX = 
    /^(([a-z]+:\/\/)?[a-z0-9\-\.]+\.[a-z]{2,4}((\/|\?).*)*)?$/i
    
  attr_accessible :url, :text
  belongs_to :event
  
  validates :url, format: {with: URL_REGEX}
  
  before_save :blank_text
  
  def self.add_http(new_url)
    protocol_regex = /^[a-z]+:\/\//
    if protocol_regex =~ new_url or new_url == ''
      new_url
    else
      'http://'+new_url
    end
  end
  
  def url=(new_url)
    write_attribute :url, Link.add_http(new_url)
  end
  
  def blank_text
    self.text = url if text.blank?
  end
end
