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
  
  validates :name,    presence: true, uniqueness: {case_sensitive: false}
  validates :address, presence: true
  validates :city,    presence: true
  
  scope :future, lambda {where("date >= ?", Time.zone.today)}
  scope :past, lambda {where("date < ?", Time.zone.today)}
  scope :today, lambda {where("date = ?", Time.zone.today)}
  scope :this_week, lambda {future.where("date < ?", 1.week.from_now)}
  scope :this_month, lambda {future.where("date < ?", 1.month.from_now)}
  
  scope :free, where("price = 0")
  scope :recently_added, 
    ->{ future.where('created_at > ?', 1.week.ago).order('created_at DESC') }
  scope :recently_updated, 
    ->{ future.where('updated_at > ?', 1.week.ago).order('updated_at DESC') }
  
  def self.cheaper_than(price)
    where("price <= ?", price.gsub('$','').gsub(',','').to_f*100)
  end
  
  def self.search(term)
    where('events.name LIKE :term OR events.description LIKE :term', 
      term: "%#{term}%")
  end
  
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
      if price_before_type_cast =~ /free/
        self.price = 0
      else
        self.price = nil
      end
    end
  end
  
  def price
    price_int = read_attribute(:price)
    if price_int == 0
      "free"
    elsif price_int && price_int > 10
      price_int.to_s.insert(-3, '.').insert(0, '$')
    elsif price_int
      price_int.to_s.insert(0, '0.0').insert(0, '$')
    else
      'no price info'
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
