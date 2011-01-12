require 'spec_helper'

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
  
  it 'should require a name.' do
    Event.new(@with_venue_attr.merge(name: '')).should_not be_valid
  end
  
  it 'should require an address.' do
    Event.new(@with_address_attr.merge(address: '')).should_not be_valid
  end
  
  it 'should require a city.' do
    Event.new(@with_address_attr.merge(city: '')).should_not be_valid
  end
  
  it 'should store the price as an integer in cents.' do
    event = Event.create(@with_venue_attr)
    event.price.should == (@with_venue_attr[:price].to_f*100).round
  end
  
  it 'should store a price that is not a number as nil.' do
    event = Event.create(@with_address_attr)
    event.price.should  be_nil
  end
  
  it 'should handle numbers with commas and dollars.' do
    event = Event.create(@with_venue_attr.merge(price: '$1,024'))
    event.price.should == 102400
  end
  
  it 'should have the appropriate date.' do
    event = Event.create(@with_venue_attr)
    event.date.year.should == 2.days.from_now.year
    event.date.month.should == 2.days.from_now.month
    event.date.day.should == 2.days.from_now.day
  end
  
  it 'should default to the local city.' do
    Event.new.city.should == WeekendGeneral::Local::city
  end
  
  it 'should contain a link for each links attribute.' do
    event = Event.create(@with_address_attr) 
    event.links.size.should == 2
  end
  
  it 'should reject invalid links.' do
    @with_venue_attr[:links_attributes] << {url: invalid_urls[0], text: ''}
    Event.new(@with_venue_attr).should_not be_valid
  end
  
  it 'should delete associated links when destroyed.' do
    event = Event.create @with_address_attr
    links = event.links
    event.destroy
    links.each { |link| Link.find_by_id(link.id).should be_nil }
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
          user.host! @event
        end
      end
      
      it "should track which users are hosting." do
        @event.hosts.should == @users
      end
      
      it "should let a user unhost an event." do
        @users[0].unhost! @event
        @event.hosts.should_not include(@users[0])
      end
    end
    
    describe "attendants" do
      before :each do
        @users.each do |user|
          user.attend! @event
        end
      end
      
      it "should track which users are hosting." do
        @event.attendees.should == @users
      end
      
      it "should let a user unhost an event." do
        @users[0].unattend! @event
        @event.attendees.should_not include(@users[0])
      end
    end
    
    describe "maybes" do
      before :each do
        @users.each do |user|
          user.maybe! @event
        end
      end
      
      it "should track which users are hosting." do
        @event.maybes.should == @users
      end
      
      it "should let a user unhost an event." do
        @users[0].unmaybe! @event
        @event.maybes.should_not include(@users[0])
      end
    end
        
    describe "combinations" do
      before :each do
        @users[0].host! @event
        @users[1].host! @event
        @users[2].attend! @event
        @users[3].attend! @event
        @users[4].maybe! @event
        @users[5].maybe! @event
      end
      
      it "should have the right event associations." do
        @event.hosts.should include(@users[0])
        @event.hosts.should include(@users[1])
        @event.attendees.should include(@users[2])
        @event.attendees.should include(@users[3])
        @event.maybes.should include(@users[4])
        @event.maybes.should include(@users[5])
      end
      
      it "should delete associations when the event is destroyed." do
        id = @event.id
        @event.destroy
        EventHost.find_by_event_id(id).should be_nil
        EventMaybe.find_by_event_id(id).should be_nil
        EventAttendee.find_by_event_id(id).should be_nil
      end
    end
  end
end
