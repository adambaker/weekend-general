class User < ActiveRecord::Base  
  attr_accessible :email, :name, :provider, :uid, :description, :theme,
    :attend_reminder, :maybe_reminder, :host_reminder, :track_host, 
    :track_attend, :track_maybe, :host_rsvp, :attend_rsvp, :maybe_rsvp,
    :new_event
  
  has_many :rsvps, dependent: :destroy
  has_many :events, through: :rsvps
  
  has_many :trails, foreign_key: :tracker_id, dependent: :destroy
  has_many :targets, through: :trails
  
  has_many :breadcrumbs, foreign_key: :target_id, class_name: 'Trail',
    dependent: :destroy
  has_many :trackers, through: :breadcrumbs

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :name,     presence:   true
  validates :email,    uniqueness: {case_sensitive: false},
                       format:     {with: email_regex}
  validates :provider, presence:   true
  validates :uid,      presence:   true,
                       uniqueness: {scope: :provider}
  validates_inclusion_of :theme, in: Themes::THEMES.keys
  
  scope :officers, where('rank > 2')
  scope :discharged, where(discharged: true)
  scope :active, where(discharged: false)
  
  def self.search(term) 
    where("users.name LIKE :term OR users.description LIKE :term", 
      term: "%#{term}%")
  end
  
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
  def events_by_kind(kind)
    events.future.includes(:rsvps).where(rsvps: {kind: kind}).order(:date)
  end
  
  def attendance(event)
    rsvp = rsvps.find_by_event_id(event.id)
    rsvp.kind if rsvp
  end  

  def host(event)
    unattend event
    rsvps.create!(event_id: event.id, kind: 'host')
  end  
  def attend(event)
    unattend event
    rsvps.create!(event_id: event.id, kind: 'attend')
  end
  def maybe(event)
    unattend event
    rsvps.create!(event_id: event.id, kind: 'maybe')
  end
  def unattend(event)
    rsvp = rsvps.find_by_event_id(event)
    rsvp.destroy if rsvp
  end
  
  def promote(user)
    return if user.rank == 4
    user.rank += 1 if self.rank == 4 || (self.rank - user.rank) > 1
    user.save
  end
  
  def tracking?(user)
    trails.find_by_target_id(user.id)
  end
  def track(user)
    trails.create!(target_id: user.id)
  end
  def untrack(user)
    trail = trails.find_by_target_id(user.id)
    trail.destroy if trail
  end
  
  def target_rsvps
    targets.reduce([]) {
      |rsvps, target| rsvps << target.rsvps.recent.limit(3)
    }.flatten
  end
end
