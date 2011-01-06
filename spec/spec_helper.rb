# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
  
  def test_sign_in(user)
    session[:user_id] = user.id
  end
  
  def venue_attr
    {
      name: 'A Happy Place',
      address: '1234 Happy Street',
      city: 'Chicago',
      url: 'www.ahappyplace.com',
      description: <<-all_good_strings
<a href="www.ahappyplace.com">A Happy Place</a> is a terrible place to go if you want to <em>hate</em> things and kill yourself. The <script> foobar</script>people look at each other with wide smiles and bloodshot eyes. Ask the bartender in the back for the Red Eye to get the optimal Happy Place experience.

Cover for events ranges from free to about $1200, so be prepared. Typically hosts goblin eating contests and thrash metal.
      all_good_strings
    }
  end
  
  def stripped_description
    <<-all_good_strings
A Happy Place is a terrible place to go if you want to hate things and kill yourself. The  foobarpeople look at each other with wide smiles and bloodshot eyes. Ask the bartender in the back for the Red Eye to get the optimal Happy Place experience.

Cover for events ranges from free to about $1200, so be prepared. Typically hosts goblin eating contests and thrash metal.
    all_good_strings
  end
  
  def escaped_description
    <<-all_good_strings
&lt;a href="www.ahappyplace.com"&gt;A Happy Place&lt;/a&gt; is a terrible place to go if you want to &lt;em&gt;hate&lt;/em&gt; things and kill yourself. The &lt;script&gt; foobar&lt;/script&gt;people look at each other with wide smiles and bloodshot eyes. Ask the bartender in the back for the Red Eye to get the optimal Happy Place experience.

Cover for events ranges from free to about $1200, so be prepared. Typically hosts goblin eating contests and thrash metal.
    all_good_strings
  end
  
  def sanitized_description
    <<-all_good_strings
<a href="www.ahappyplace.com">A Happy Place</a> is a terrible place to go if you want to <em>hate</em> things and kill yourself. The people look at each other with wide smiles and bloodshot eyes. Ask the bartender in the back for the Red Eye to get the optimal Happy Place experience.
     
Cover for events ranges from free to about $1200, so be prepared. Typically hosts goblin eating contests and thrash metal.
    all_good_strings
  end
  
end
