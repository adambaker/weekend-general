class DishonorableDischarge < ActiveRecord::Base
  attr_accessible :email, :provider, :uid, :officer, :reason

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :reason,   presence: true
  validates :email,    format:   {with: email_regex}
  validates :provider, presence: true
  validates :uid,      presence: true
  validates :officer,  presence: true
  validates_each :officer do |m, attr, val|
    if( !val || !User.exists?(val) || User.find(val).rank < 3 )
      m.errors.add(attr, "must have officer rank")
    end
  end
end
