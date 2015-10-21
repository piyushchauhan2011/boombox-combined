require 'tsv'

parsed_uf = TSV.parse_file('/Users/kartikeychauhan/Documents/college/COMP5338 Advanced Data Models/hetrec2011-lastfm-2k-2/user_friends.dat').with_header

parsed_uf.each do |x|
  u1 = User.find_or_create_by(userID: x[0].to_i)
  u2 = User.find_or_create_by(userID: x[1].to_i)
  if (u1.friends.to_a == [])
    u1.friends << u2
    u1.save
  end
end
