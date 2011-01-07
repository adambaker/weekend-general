class Venue < ActiveRecord::Base
  url_regex = 
    /^(([a-z]+:\/\/)?[a-z0-9\-\.]+\.[a-z]{2,3}(\/[a-z0-9\-_+ %]+)*(\?.*)?)?$/i
    
  attr_accessible :name, :address, :city, :url, :description
  
  validates :name, presence:   true,
                   uniqueness: {scope: [:address, :city]}
  validates :url,  format:     {with: url_regex}
  validates :city, presence:   true
  
  def url
    protocol_regex = /^[a-z]+:\/\//
    stored = read_attribute(:url)
    if protocol_regex =~ stored or stored==''
      stored
    else
      'http://'+stored
    end
  end
  
end
