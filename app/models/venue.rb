class Venue < ActiveRecord::Base
  url_regex = 
    /^(([a-z]+:\/\/)?[a-z0-9\-\.]+\.[a-z]{2,3}(\/[a-z0-9\-_+ %]+)*(\?.*)?)?$/i
    
  attr_accessible :name, :address, :city, :url, :description
  
  validates :name, presence:   true,
                   uniqueness: {scope: [:address, :city]}
  validates :url,  format:     {with: url_regex}
  validates :city, presence:   true
  
  def url=(new_url)
    protocol_regex = /^[a-z]+:\/\//
    if protocol_regex =~ new_url or new_url == ''
      write_attribute :url, new_url
    else
      write_attribute :url, 'http://'+new_url
    end
  end
end
