class Venue < ActiveRecord::Base
    
  attr_accessible :name, :address, :city, :url, :description
  has_many :events
  
  validates :name,    presence:   true,
                      uniqueness: {scope: [:address, :city]}
  validates :url,     format:     {with: Link::URL_REGEX}
  validates :address, presence:   true
  validates :city,    presence:   true
  
  def url=(new_url)
    write_attribute :url, Link.add_http(new_url)
  end
  
  def self.search(term)
    where('venues.name LIKE :term OR venues.description LIKE :term', 
      term: "%#{term}%")
  end
end
