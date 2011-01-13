module EventsHelper
  def venue_options
    venues = Venue.all.map {|venue| [venue.name+' @ '+venue.address, venue.id]}
    venues.insert(0, ['--', 'no_venue'])
  end
end
