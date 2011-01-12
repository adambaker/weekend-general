class Rsvp < ActiveRecord::Base
  attr_accessible :event_id, :kind
  
  belongs_to :event
  belongs_to :user
  
  validates :event_id, presence: true
  validates :user_id,  presence: true
  validates :kind,     presence: true
end
