class User < ActiveRecord::Base
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :email, :name, :provider, :uid
  
  has_many :event_hosts, dependent: :destroy
  has_many :hosting, through: :event_hosts, source: :event
  
  has_many :event_attendees, dependent: :destroy
  has_many :attending, through: :event_attendees, source: :event
  
  has_many :event_maybes, dependent: :destroy
  has_many :maybe, through: :event_maybes, source: :event
  
  validates :name,     presence:   true
  validates :email,    uniqueness: {case_sensitive: false},
                       format:     {with: email_regex}
  validates :provider, presence:   true
  validates :uid,      presence:   true,
                       uniqueness: {scope: :provider}
         
  before_save :check_admin
  
  def check_admin
    self.admin = true if super_admin?
  end
  
  def super_admin? #planning on letting super admins add and remove admins
    WeekendGeneral::Local.admins.include? self.email
  end
  
  def host!(event)
    event_hosts.create!(event_id: event.id)
  end
  
  def unhost!(event)
    event_hosts.find_by_event_id(event).destroy
  end
  
  def attend!(event)
    event_attendees.create!(event_id: event.id)
  end
  
  def unattend!(event)
    event_attendees.find_by_event_id(event).destroy
  end
  
  def maybe!(event)
    event_maybes.create!(event_id: event.id)
  end
  
  def unmaybe!(event)
    event_maybes.find_by_event_id(event).destroy
  end
end
