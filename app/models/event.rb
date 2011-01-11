class Event < ActiveRecord::Base
  attr_accessible :name, :date, :time, :price, :venue, :address, :city, :links,
    :description
  
  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true

  belongs_to :venue
  has_many :links
  
  accepts_nested_attributes_for :links
  
  before_validation :venue_address
  before_save :convert_price
  
  def initialize(attrs = {}, &block)
    attrs[:city] = WeekendGeneral::Local::city if attrs[:city].nil?
    super
  end
  
  def venue_address
    unless venue.nil?
      self.address = venue.address
      self.city = venue.city
    end
  end
  
  def convert_price
    begin
      self.price = (Float(
          price_before_type_cast.strip.gsub('$','').gsub(',',''))*100
        ).round
    rescue ArgumentError
      self.price = nil
    end
  end
end
