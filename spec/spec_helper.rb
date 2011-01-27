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
    user
  end
  
  def sign_in_path
    '/auth/google'
  end
  
  def venue_attr
    {
      name: 'A Happy Place',
      address: '1234 Happy Street',
      city: 'Chicago',
      url: 'http://www.ahappyplace.com',
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
  
  def sanitized_description
    <<-all_good_strings
<a href="www.ahappyplace.com">A Happy Place</a> is a terrible place to go if you want to <em>hate</em> things and kill yourself. The people look at each other with wide smiles and bloodshot eyes. Ask the bartender in the back for the Red Eye to get the optimal Happy Place experience.
     
Cover for events ranges from free to about $1200, so be prepared. Typically hosts goblin eating contests and thrash metal.
    all_good_strings
  end
  
  def valid_urls
    [ 'http://foo.bar.com', 'www.go-here-now.il', 'find.us/',
      'punch.com/users/1/get?foo=1&bar=2', 'http://go.co?goo=foo',
      'am.de/pan_da+all/man?squill=seminal', 'foo.co?e=foo%40goo.co', '',
      'http://aurgasm.us/music/michelle/warpaint-undertow.mp3',
      'https://www.etix.com/ticket/servlet/onlineSale%3bjsessionid=A2BE74614CD1D727A56F2C2B790178BC?action=selectPerformance&cobrand=metrochicago&performance_id=1356571' ]
  end
  
  def invalid_urls
    ['foo', 'foo?a=12', 'game/tell.us', '1934://punt.me',
      'sq\\id://foo.bar', 'www.foo.bar.com/seven-tell()/go' ]
  end
  
  def valid_event_attr
    { 
      name: 'war and famine',
      'date(1i)' => 2.weeks.from_now.year.to_s,
      'date(2i)' => 2.weeks.from_now.month.to_s,
      'date(3i)' => 2.weeks.from_now.day.to_s,
      time: '9pm', 
      price: '',
      venue_id: 'none',
      address: '1234 Evil hill',
      city: 'Chicago, Il',
      links_attributes: [],
      description: ''
    }
  end
  
  def set_rank( user, rank )
    user.rank = rank
    user.save
  end
  
  def set_creator(object, user)
    object.created_by = user
    object.save
  end
  
  def test_flash(type, controller, message = nil)
    flash[type].should_not be_nil
    flash[type].should == Themes::default_theme[controller][message]
  end
  
  def test_rank_flash
    flash[:error].should_not be_nil
    flash[:error].should == Themes::default_theme['rank']
  end
  
  def test_sanitized_description
    paragraphs = sanitized_description.split("\n")
    response.should have_selector 'p a', href: 'www.ahappyplace.com',
                                          content: 'A Happy Place'
    response.should have_selector 'p em', content: 'hate'
    response.should have_selector 'p', content: 'Red Eye'
    response.should have_selector 'p', content: paragraphs[2]
    response.should_not have_selector 'p script'
  end
  
  def test_attrs_equal(object, attrs)
    object.reload
    attrs.each do |key, value|
      object.send(key).should == value
    end 
  end
  
  def mail_event_date(event)
    date_format = '%A, %B %d'
    date_format += ' %Y' unless event.date.year == Time.zone.now.year
    event.date.strftime(date_format)
  end
end
