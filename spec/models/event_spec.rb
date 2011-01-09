require 'spec_helper'

describe Event do
  before :each do
    @venue = Factory(:venue)
    @with_venue_attr = 
      {
        name: "a happy gathering",
        date: 2.days.from_now,
        time: nil,
        price: '21.40',
        venue: @venue.id,
        address: nil,
        description: venue_attr[:description]
      }
    @with_address_attr = @event_w_venue_attr.merge name: 'war and famine',
        time: '9pm', venue: nil, address: '1234 Evil hill'
  end
end
