module EventsHelper
  def venue_options
    venues = Venue.order(:name).all.map do |venue| 
      [venue.name+' @ '+venue.address, venue.id]
    end
    venues.insert(0, ['--', 'no_venue'])
  end
end
