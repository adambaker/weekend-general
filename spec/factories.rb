Factory.define :user do |user|
  user.name     "user"
  user.email    "user@example.com"
  user.provider "google"
  user.uid      "foobar"
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.sequence :uid do |n|
  "id-#{n}"
end

Factory.define :venue do |venue|
  venue.name        'A Happy Place'
  venue.address     '1234 Happy Street'
  venue.city        'Chicago'
  venue.url         'www.ahappyplace.com'
  venue.description <<-all_good_strings
        <a href="www.ahappyplace.com">A Happy Place</a> is a terrible place to 
        go if you want to <em>hate</em> things and kill yourself. The 
        <script> foobar</script>people look at each other with wide smiles and
        bloodshot eyes. Ask the bartender in the back for the Red Eye to get 
        the optimal Happy Place experience.
        
        Cover for events ranges from free to about $1200, so be prepared. 
        Typically hosts goblin eating contests and thrash metal.
  all_good_strings
end

Factory.sequence :venue_name do |n|
  "Place #{n}"
end
