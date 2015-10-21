require 'tsv'

parsed_artists = TSV.
  parse_file('/Users/kartikeychauhan/Documents/college/COMP5338 Advanced Data Models/hetrec2011-lastfm-2k-2/artists.dat')
  .with_header

parsed_artists.each do |x|
  artist = AllArtist.new
  artist.artistID = x[0].to_i
  artist.name = x[1]
  artist.url = x[2]
  artist.picture_url = x[3]
  artist.save
end
