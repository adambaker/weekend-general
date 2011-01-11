class Venue < ActiveRecord::Base
    
  attr_accessible :name, :address, :city, :url, :description
  
  validates :name, presence:   true,
                   uniqueness: {scope: [:address, :city]}
  validates :url,  format:     {with: Link::URL_REGEX}
  validates :city, presence:   true
  
  def url=(new_url)
    write_attribute :url, Link.add_http(new_url)
  end
end
