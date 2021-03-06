require 'spec_helper'
require 'set'

describe Event do
  before :each do
    @venue = Factory(:venue)
    @with_venue_attr = 
      {
        name: "a happy gathering",
        'date(1i)' => 2.days.from_now.year.to_s,
        'date(2i)' => 2.days.from_now.month.to_s,
        'date(3i)' => 2.days.from_now.day.to_s,
        time: '',
        price: '21.40',
        venue_id: @venue.id.to_s,
        address: '',
        city: '',
        links_attributes: [],
        description: ''
      }
    @with_address_attr = 
      { 
        name: 'war and famine',
        'date(1i)' => 2.weeks.from_now.year.to_s,
        'date(2i)' => 2.weeks.from_now.month.to_s,
        'date(3i)' => 2.weeks.from_now.day.to_s,
        time: '9pm', 
        price: '',
        venue_id: '',
        address: '1234 Evil hill',
        city: 'Chicago, Il',
        links_attributes: [
          {url: 'http://www.sadhole.co', text: 'Sad hole.'},
          {url: 'www.goldenforest.org', text: 'Desecration target'}
        ],
        description: venue_attr[:description]
      }
  end
  
  it 'should create a new instance with valid attributes.' do
    Event.create!(@with_venue_attr)
    Event.create!(@with_address_attr)
  end
  
  it "should use the venue's address when a venue is given." do
    event = Event.create @with_venue_attr
    event.address.should == @venue.address
    event.city.should == @venue.city
  end
  
  it 'should require a unique name/date combo.' do
    Event.new(@with_venue_attr.merge(name: '')).should_not be_valid
    Event.create(@with_venue_attr)
    Event.new(@with_venue_attr).should_not be_valid
    @with_venue_attr[:name].upcase!
    Event.new(@with_venue_attr).should_not be_valid
    Event.new(@with_venue_attr.merge(
        'date(3i)' => 4.days.from_now.day.to_s
      )
    ).should be_valid
  end
  
  it 'should require an address.' do
    Event.new(@with_address_attr.merge(address: '')).should_not be_valid
  end
  
  it 'should require a city.' do
    Event.new(@with_address_attr.merge(city: '')).should_not be_valid
  end
  
  it 'should return the same price specified.' do
    event = Event.create(@with_venue_attr)
    event.price.should == '$'+@with_venue_attr[:price]
  end
  
  it 'should present no price info as "no price info".' do
    event = Event.create(@with_address_attr)
    event.price.should =~ /no price info/
  end
  
  it 'should handle numbers with commas and dollars.' do
    event = Event.create(@with_venue_attr.merge(price: '$1,024'))
    event.price.should == '$1024.00'
  end
  
  it 'should return "free" when free is specified.' do
    event = Event.create(@with_venue_attr.merge(price: 'free'))
    event.price.should == 'free'
  end
  
  it 'should have the appropriate date.' do
    event = Event.create(@with_venue_attr)
    event.date.year.should == 2.days.from_now.year
    event.date.month.should == 2.days.from_now.month
    event.date.day.should == 2.days.from_now.day
  end
  
  it 'should default to the local city.' do
    Event.new.city.should == Settings::city
  end
  
  it 'should contain a link for each links attribute.' do
    event = Event.create(@with_address_attr) 
    event.links.size.should == 2
  end
  
  it 'should reject invalid links.' do
    @with_venue_attr[:links_attributes] << {url: invalid_urls[0], text: ''}
    Event.new(@with_venue_attr).should_not be_valid
  end
  
  it 'should silently reject blank links.' do
    @with_address_attr[:links_attributes] << {url: '', text: 'foo'}
    Event.create!(@with_address_attr).links.size.should == 2
  end
  
  it 'should delete associated links when destroyed.' do
    event = Event.create @with_address_attr
    links = event.links
    event.destroy
    links.each { |link| Link.find_by_id(link.id).should be_nil }
  end
  
  it 'should have a created by attribute.' do
    Event.create(@with_venue_attr).should respond_to :created_by
  end
  
  describe "users attending" do
    before :each do
      @event = Event.create(@with_venue_attr)
      @users = [Factory(:user)]
      5.times { @users << Factory(:user, uid: Factory.next(:uid),
        email: Factory.next(:email)) }
    end
    
    describe "hosts" do
      before :each do
        @users.each do |user|
          user.host @event
        end
      end
      
      it "should track which users are hosting." do
        @event.hosts.should == @users
      end
      
      it "should let a user unhost an event." do
        @users[0].unattend @event
        @event.hosts.should_not include(@users[0])
      end
    end
    
    describe "attendants" do
      before :each do
        @users.each do |user|
          user.attend @event
        end
      end
      
      it "should track which users are hosting." do
        @event.attendees.should == @users
      end
      
      it "should let a user unhost an event." do
        @users[0].unattend @event
        @event.attendees.should_not include(@users[0])
      end
    end
    
    describe "maybes" do
      before :each do
        @users.each do |user|
          user.maybe @event
        end
      end
      
      it "should track which users are hosting." do
        @event.maybes.should == @users
      end
      
      it "should let a user unhost an event." do
        @users[0].unattend @event
        @event.maybes.should_not include(@users[0])
      end
    end
        
    describe "combinations" do
      before :each do
        @users[0].host @event
        @users[1].host @event
        @users[2].attend @event
        @users[3].attend @event
        @users[4].maybe @event
        @users[5].maybe @event
      end
      
      it "should have the right event associations." do
        @event.hosts.should include(@users[0])
        @event.hosts.should include(@users[1])
        @event.attendees.should include(@users[2])
        @event.attendees.should include(@users[3])
        @event.maybes.should include(@users[4])
        @event.maybes.should include(@users[5])
        @event.users.should == @users
      end
      
      it "should delete associations when the event is destroyed." do
        id = @event.id
        @event.destroy
        Rsvp.find_by_event_id(id).should be_nil
      end
    end
  end
  
  describe "event orderings and scopes" do
    def id_date_set(events)
      events.map{|e| [e.id, e.date.day]}.to_set
    end
    
    before :each do
      @today_event = Factory(:event, 
        name: Factory.next(:name), date: Time.zone.today, price: '30')
      @this_week_events = [ 
        Factory(:event, date: Time.zone.today + 1.day), 
        Factory(:event, name: Factory.next(:name), 
          date: 2.days.from_now.beginning_of_day),
        @today_event
      ]
      @past_events = [
        Factory(:event, name: Factory.next(:name), 
          date: 2.days.ago.beginning_of_day),
        Factory(:event, name: Factory.next(:name), 
          date: 1.day.ago.beginning_of_day)
      ]
      @past_events.reverse!
      @far_future_events = [
        Factory(:event, name: Factory.next(:name), 
          date: 2.months.from_now.beginning_of_day, price: '10'),
        Factory(:event, name: Factory.next(:name), 
          date: 2.months.from_now.beginning_of_day, price: '0')
      ]
      @this_month_events = [
        Factory(:event, name: Factory.next(:name), 
          date: 2.weeks.from_now.beginning_of_day, price: "20"),
        Factory(:event, name: Factory.next(:name), 
          date: 2.weeks.from_now.beginning_of_day, price: '0')
      ] + @this_week_events
      @future_events = @this_month_events + @far_future_events
      @free_events = [@far_future_events[1], @this_month_events[1]]
      @cheap_events = @free_events + [@far_future_events[0]]
    end
    
    #below events are mapped to sets of id, date pairs to make failure
    #messages easy to read and informative
    it "should have future events in 'future'." do
      id_date_set(Event.future.all).should == 
        id_date_set(@future_events)
    end
    
    it "should have past events in 'past'." do
      id_date_set(Event.past.all).should == id_date_set(@past_events)
    end
    
    it "should have today's events in 'today'." do
      Event.today.all.size.should == 1
      Event.today.first.id.should == @today_event.id
    end
    
    it "should have this week's events in 'this_week'." do
      id_date_set(Event.this_week.all).should == id_date_set(@this_week_events)
    end
    
    it "should have this month's events in 'this_month." do
      id_date_set(Event.this_month.all).should == 
        id_date_set(@this_month_events)
    end
    
    it "should have free events in 'free'." do
      Event.free.to_set.should == @free_events.to_set
    end
    
    it "should have cheap events in 'cheaper_than(10)." do
      Event.cheaper_than('10').to_set.should == @cheap_events.to_set
    end
    
    describe "recent activity" do 
      before :each do
        @recent = @future_events - [@far_future_events[0], @today_event]
        @recent.each_index do |i|
          @recent[i].created_at = i.days.ago
          @recent[i].save
        end
        @far_future_events[0].created_at = 10.days.ago
        @far_future_events[0].save
        @today_event.created_at = 10.days.ago
        @today_event.save
        
        @updated = @future_events - @free_events
        @updated.each_index do |i|
          @updated[i].updated_at = i.days.ago
          @updated[i].save
        end
        @free_events.each{|e| e.updated_at = 10.days.ago; e.save}
      end
      
      it "should not have past events or events added long ago in " +   
        "recently_added." do
        recent = Event.recently_added.all
        recent.size.should == @recent.size
        recent.should_not include @today_event
        recent.should_not include @far_future_events[0]
        recent.should_not include @past_events[0]
        recent.should_not include @past_events[1]
      end
      
      it "should sort recently_added most recent first." do
        Event.recently_added.all.should == 
          @recent.sort{|a,b| b.created_at <=> a.created_at}
      end
      
      it "should not have past or distantly updated events in" + 
        " recently updated." do
        update = Event.recently_updated.all
        update.size.should == @updated.size
        update.should_not include @free_events[0]
        update.should_not include @free_events[1]
        update.should_not include @past_events[0]
        update.should_not include @past_events[1]
      end
      
      it "should sort recently updated events most recent first." do
        Event.recently_updated.all.should == 
          @updated.sort{|a,b| b.updated_at <=> a.updated_at}
      end
    end
  end
  
  describe "search" do
    before :each do
      @event = Factory :event
      @poop = Factory(:event, name: 'Poopyface')
      @nincompoop = Factory(:event, name: 'Nincompoop Bonanza')
      @cellar = Factory(:event, name: Factory.next(:name), 
        description: 'Help me escape the cellar!')
    end
    
    it "should not contain @event or @cellar." do
      Event.search('poop').should_not include(@event)
      Event.search('poop').should_not include(@cellar)
    end
    
    it "should contain @poop and @nincompoop." do
      poop = Event.search('poop')
      poop.should include(@poop)
      poop.should include(@nincompoop)
      poop.size.should == 2
    end
    
    it "should contain @cellar when searching 'cellar'" do
      cellar = Event.search('cellar')
      cellar.should include(@cellar)
      cellar.size.should == 1
    end
  end
end
