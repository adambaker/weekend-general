Factory.define :user do |user|
  user.name                  "user"
  user.email                 "user@example.com"
  user.provider              "google"
  user.uid                   "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.sequence :uid do |n|
  "id-#{n}"
end
