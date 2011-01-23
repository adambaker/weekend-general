class User < ActiveRecord::Base
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :email, :name, :provider, :uid, :description, :theme
  
  has_many :rsvps, dependent: :destroy
  has_many :events, through: :rsvps
  
  validates :name,     presence:   true
  validates :email,    uniqueness: {case_sensitive: false},
                       format:     {with: email_regex}
  validates :provider, presence:   true
  validates :uid,      presence:   true,
                       uniqueness: {scope: :provider}
  validates_inclusion_of :theme, in: Themes::THEMES.keys
  
  def initialize(attrs={}, &block)
    attrs[:theme] = Themes::default_theme['name'] if attrs[:theme].nil?
    super
    self.rank = 4 if Settings::majors.include? email 
  end
  
  def hosting
    events_by_kind('host')
  end
  
  def attending
    events_by_kind 'attend'
  end
  
  def maybes
    events_by_kind 'maybe'
  end
  
  def attendance(event)
    rsvp = rsvps.find_by_event_id(event.id)
    rsvp and rsvp.kind
  end
  
  def events_by_kind(kind)
    events.future.includes(:rsvps).where(rsvps: {kind: kind}).order(:date)
  end
  
  def host(event)
    unattend event
    rsvps.create!(event_id: event.id, kind: 'host')
  end
  
  def attend(event)
    unattend event
    rsvps.create!(event_id: event.id, kind: 'attend')
  end
  
  def unattend(event)
    rsvp = rsvps.find_by_event_id(event)
    rsvp.destroy unless rsvp.nil?
  end
  
  def maybe(event)
    unattend event
    rsvps.create!(event_id: event.id, kind: 'maybe')
  end
  
  def promote
    self.rank += 1
  end
end
