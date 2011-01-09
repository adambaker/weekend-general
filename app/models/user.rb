class User < ActiveRecord::Base
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :provider, :uid
  
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
  
end
