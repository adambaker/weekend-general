class DishonorableDischarge < ActiveRecord::Base
  attr_accessible :email, :provider, :uid, :officer, :reason

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  validates :reason,   presence: true
  validates :email,    format:   {with: email_regex}
  validates :provider, presence: true
  validates :uid,      presence: true
end
