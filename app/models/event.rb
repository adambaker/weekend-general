class Event < ActiveRecord::Base
  attr_accessible :name, :date, :time, :price, :venue_id, :address, :city,
    :description, :links_attributes

  belongs_to :venue
  has_many :links, dependent: :destroy
  
  has_many :event_hosts, dependent: :destroy
  has_many :hosts, through: :event_hosts, source: :user
  
  has_many :event_attendees, dependent: :destroy
  has_many :attendees, through: :event_attendees, source: :user
  
  has_many :event_maybes, dependent: :destroy
  has_many :maybes, through: :event_maybes, source: :user
  
  validates_associated :links
  accepts_nested_attributes_for :links
  
  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  
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
    rescue Exception
      self.price = nil
    end
  end
end
