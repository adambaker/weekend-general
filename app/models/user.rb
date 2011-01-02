class User < ActiveRecord::Base
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :provider, :uid
  
  validates :name,     presence:   true
  validates :email,    presence:   true, 
                       uniqueness: {case_sensitive: false},
                       format:     {with: email_regex}
  validates :provider, presence:   true
  validates :uid,      presence:   true,
                       uniqueness: {scope: :provider}
end
