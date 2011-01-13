class Event < ActiveRecord::Base
  attr_accessible :name, :date, :time, :price, :venue_id, :address, :city,
    :description, :links_attributes

  belongs_to :venue
  has_many :links, dependent: :destroy
  
  has_many :rsvps, dependent: :destroy
  has_many :users, through: :rsvps
  
  validates_associated :links
  accepts_nested_attributes_for :links,
    reject_if: proc {|attr| attr[:url].blank?}
  
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :address, presence: true
  validates :city, presence: true
  
  before_validation :venue_address
  before_save :convert_price
  
  def initialize(attrs = {}, &block)
    attrs[:city] = Settings::city if attrs[:city].nil?
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
  
  def hosts
    users_by_kind 'host'
  end
  
  def attendees
    users_by_kind 'attend'
  end
  
  def maybes
    users_by_kind 'maybe'
  end
  
  def users_by_kind(kind)
    rsvps.where(kind: kind).map{|r| r.user}
  end
end
