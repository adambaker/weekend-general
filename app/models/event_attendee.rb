class EventAttendee < ActiveRecord::Base
  attr_accessible :event_id
  
  belongs_to :user
  belongs_to :event
  
  validates :user_id,  presence: true
  validates :event_id, presence: true
end
