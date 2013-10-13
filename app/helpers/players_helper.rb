module PlayersHelper
  def venue_options
    Venue.order("name ASC").all.map { |venue| [venue.name, venue.id] }
  end
end
