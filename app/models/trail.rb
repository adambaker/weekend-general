class Trail < ActiveRecord::Base
  attr_accessible :target_id
  
  belongs_to :tracker, class_name: 'User'
  belongs_to :target, class_name: 'User'
  
  validates :tracker_id, presence: true
  validates :target_id,  presence: true
end
