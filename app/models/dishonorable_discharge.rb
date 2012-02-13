class DishonorableDischarge < ActiveRecord::Base
  attr_accessible :user_id, :reason

  validates :reason,     presence: true
  validates :user_id,    presence: true
  validates :officer_id, presence: true
  validates_each :officer_id do |m, attr, val|
    officer = val && User.find(val);
    if( !officer || officer.rank < 3 )
      m.errors.add(attr, "must have officer rank")
    end
  end

  after_save do |discharge|
    discharge.user.discharge
  end

  belongs_to :user
  belongs_to :officer, class_name: 'User'
end
