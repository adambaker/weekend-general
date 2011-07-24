class Rsvp < ActiveRecord::Base
  attr_accessible :event_id, :kind
  
  belongs_to :event
  belongs_to :user
  
  validates :event_id, presence: true
  validates :user_id,  presence: true
  validates_inclusion_of :kind, in: %w(host attend maybe)
  
  scope :recent, ->{ where('rsvps.created_at >= ?', 1.week.ago)
    .includes(:event).where('events.date >= ?', Time.zone.today)
    .order('rsvps.created_at DESC') }
end
